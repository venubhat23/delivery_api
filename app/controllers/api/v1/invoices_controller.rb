module Api
  module V1
    class InvoicesController < ApplicationController
      # GET /api/v1/invoices
      def index
        invoices = fetch_invoices_for_current_context

        render json: {
          count: invoices.size,
          total_amount: invoices.sum(:total_amount).to_f,
          invoices: invoices.as_json
        }, status: :ok
      end

      private

      def fetch_invoices_for_current_context
        if current_user.is_a?(Customer)
          Invoice.by_customer(current_user.id).order(invoice_date: :desc)
        elsif current_user.respond_to?(:admin?) && (current_user.admin? || current_user.delivery_person?)
          if params[:customer_id].present?
            Invoice.by_customer(params[:customer_id]).order(invoice_date: :desc)
          else
            # Admin/delivery_person can see recent invoices if no filter
            Invoice.order(invoice_date: :desc).limit(100)
          end
        else
          Invoice.none
        end
      end
    end
  end
end