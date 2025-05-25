module Api
  module V1
    class DeliveriesController < ApplicationController
      before_action :ensure_delivery_person
      
      # POST /api/v1/deliveries/start
      def start
        # Find the nearest customer based on current coordinates
        current_lat = params[:current_lat].to_f
        current_lng = params[:current_lng].to_f
        
        # Find customers with pending deliveries for this delivery person
        pending_deliveries = DeliveryAssignment.where(user_id: current_user.id, scheduled_date: Date.today, status: "pending").includes(:customer)
        
        if pending_deliveries.empty?
          return render json: { message: "All deliveries completed for today." }, status: :ok
        end
        
        # Find the nearest customer
        nearest_delivery = find_nearest_delivery(pending_deliveries, current_lat, current_lng)
        
        if nearest_delivery
          # Mark delivery as in progress
          nearest_delivery.update(status: 'in_progress')
          render json: {
            delivery_id: nearest_delivery.id,
            customer: nearest_delivery.customer.as_json(except: [:user_id]),
            products: nearest_delivery.product
          }, status: :ok
        else
          render json: { message: "No deliveries found." }, status: :not_found
        end
      end
      
      # POST /api/v1/deliveries/:id/complete
      def complete
        delivery = DeliveryAssignment.find(params[:id])
        
        # Check if this delivery belongs to the current delivery person
        delivery.update(status: 'completed', completed_at: Date.today)
        # Get the next nearest delivery
        current_lat = params[:current_lat].to_f
        current_lng = params[:current_lng].to_f
        
        pending_deliveries = DeliveryAssignment.where(user_id: current_user.id, scheduled_date: Date.today, status: "pending").includes(:customer)
        nearest_delivery = find_nearest_delivery(pending_deliveries, current_lat, current_lng)

        if pending_deliveries.empty?
          render json: { message: "All deliveries completed for today." }, status: :ok
        else
          pending_deliveries.update(status: 'in_progress')
          render json: {
            delivery_id: nearest_delivery.id,
            customer: nearest_delivery.customer.as_json(except: [:user_id]),
            products: nearest_delivery.product
          }, status: :ok
        end
      end
      
      # GET /api/v1/deliveries/customers
      def customers
        if current_user.delivery_person?
          # Get all customers assigned to this delivery person
          assigned_customers = Customer.joins(:deliveries)
                                      .where(deliveries: { user_id: current_user.id })
                                      .distinct
          
          render json: assigned_customers, status: :ok
        else
          render json: { error: "Only delivery personnel can access this endpoint" }, status: :unauthorized
        end
      end
      
      private
      
      def ensure_delivery_person
        unless current_user.delivery_person?
          render json: { error: "Only delivery personnel can perform this action" }, status: :unauthorized
        end
      end
      
      def find_nearest_delivery(deliveries, current_lat, current_lng)
        nearest = nil
        min_distance = Float::INFINITY
        
        deliveries.each do |delivery|
          customer = delivery.customer
          distance = Geocoder::Calculations.distance_between(
            [current_lat, current_lng],
            [customer.latitude, customer.longitude]
          )
          
          if distance < min_distance
            min_distance = distance
            nearest = delivery
          end
        end
        
        nearest
      end
    end
  end
end
