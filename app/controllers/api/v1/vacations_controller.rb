module Api
  module V1
    class VacationsController < ApplicationController
      # POST /api/v1/vacations
      def create
        customer = ensure_customer!
        return unless customer

        vacation = customer.vacations.new(vacation_params)
        vacation.end_date ||= vacation.start_date

        ActiveRecord::Base.transaction do
          vacation.save!
          cancel_delivery_assignments_for(customer, vacation.start_date, vacation.end_date)
        end

        render json: { message: "Vacation created", vacation: vacation }, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: vacation.errors.full_messages }, status: :unprocessable_entity
      end

      # GET /api/v1/vacations
      def index
        customer = ensure_customer!
        return unless customer

        vacations = customer.vacations.order(start_date: :desc)
        render json: vacations, status: :ok
      end

      private

      def vacation_params
        params.require(:vacation).permit(:start_date, :end_date, :notes)
      end

      def ensure_customer!
        if current_user.is_a?(Customer)
          current_user
        else
          render json: { error: "Only customers can manage vacations" }, status: :unauthorized
          nil
        end
      end

      def cancel_delivery_assignments_for(customer, start_date, end_date)
        DeliveryAssignment.where(customer_id: customer.id, scheduled_date: start_date..end_date, status: 'pending').find_each do |assignment|
          assignment.destroy!
        end
      end
    end
  end
end