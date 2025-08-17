module Api
  module V1
    class VacationsController < ApplicationController
      # POST /api/v1/vacations
      def create
        ActiveRecord::Base.transaction do
          customer = resolve_customer!
          start_date = Date.parse(params.require(:start_date))
          end_date = Date.parse(params.require(:end_date))
          reason = params[:reason]
          merge_overlaps = ActiveModel::Type::Boolean.new.cast(params[:mergeOverlaps])
          idempotency_key = request.headers['Idempotency-Key']

          if idempotency_key.present?
            existing = UserVacation.find_by(customer_id: customer.id, idempotency_key: idempotency_key)
            if existing
              return render json: decorate_create_response(existing), status: :ok
            end
          end

          vacation = UserVacation.new(
            customer_id: customer.id,
            start_date: start_date,
            end_date: end_date,
            reason: reason,
            status: 'active',
            idempotency_key: idempotency_key,
            created_by: current_user.admin? ? current_user : nil
          )

          if merge_overlaps
            vacation.skip_overlap_validation!
          else
            if UserVacation.for_customer(customer.id).active_or_paused.overlapping(start_date, end_date).exists?
              return render json: { error: 'Vacation overlaps with an existing active/paused vacation' }, status: :conflict
            end
          end

          vacation.save!

          # Apply assignment updates
          affected_count = apply_skip_to_assignments(customer.id, start_date, end_date)
          vacation.update_column(:affected_assignments_skipped, affected_count)

          render json: decorate_create_response(vacation), status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
      rescue Date::Error
        render json: { error: 'Invalid date format' }, status: :bad_request
      end

      private

      # Determine the customer making the request or provided via params (admin override)
      def resolve_customer!
        if current_user.is_a?(User) && current_user.admin?
          Customer.find(params.require(:customer_id))
        elsif current_user.is_a?(Customer)
          current_user
        else
          Customer.find_by!(user_id: current_user.id)
        end
      end

      # Cutoff-aware update of delivery assignments to skipped_vacation within [start_date, end_date]
      def apply_skip_to_assignments(customer_id, start_date, end_date)
        cutoff_hour = (ENV['DAILY_CUTOFF_HOUR'] || '17').to_i
        today = Date.current
        now = Time.current
        # Never modify past dates
        effective_start = [start_date, today].max

        # Same-day after cutoff: do not affect today's assignment
        if start_date <= today && now.hour >= cutoff_hour
          effective_start = [today + 1.day, start_date].max
        end

        return 0 if effective_start > end_date

        assignments = DeliveryAssignment.where(customer_id: customer_id, scheduled_date: effective_start..end_date)
        # Only pending future/today assignments are affected
        updatable = assignments.where(status: ['pending'])
        affected = 0

        updatable.find_each(batch_size: 500) do |assignment|
          assignment.update_columns(status: 'skipped_vacation')
          affected += 1
        end

        affected
      end

      def decorate_create_response(vacation)
        {
          id: vacation.id,
          customer_id: vacation.customer_id,
          start_date: vacation.start_date,
          end_date: vacation.end_date,
          status: vacation.status,
          reason: vacation.reason,
          affectedAssignmentsSkipped: vacation.affected_assignments_skipped
        }
      end
    end
  end
end