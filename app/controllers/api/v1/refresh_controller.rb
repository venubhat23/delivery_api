module Api
  module V1
    class RefreshController < ApplicationController
      # POST /api/v1/refresh
      def create
        customers = Customer.active.order(:id).limit(1000).as_json(only: [:id, :name, :address, :phone_number, :email, :preferred_language, :delivery_time_preference, :notification_method])
        delivery_personnel = User.where(role: 'delivery_person').order(:id).as_json(only: [:id, :name, :phone])

        render json: {
          customers: customers,
          delivery_personnel: delivery_personnel,
          refreshed_at: Time.current
        }, status: :ok
      end
    end
  end
end