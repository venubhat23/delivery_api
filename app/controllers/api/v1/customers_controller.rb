module Api
  module V1
    class CustomersController < ApplicationController
      # POST /api/v1/customers/:id/update_location
      def update_location
        customer = Customer.find(params[:id])
        
        # Only delivery person or admin can update customer location
        unless current_user.delivery_person? || current_user.admin?
          return render json: { error: "Unauthorized to update customer location" }, status: :unauthorized
        end
        
        if customer.update(customer_location_params)
          render json: {
            message: "Customer address and location updated successfully.",
            customer: {
              id: customer.id,
              name: customer.name,
              updated_address: customer.address,
              lat: customer.latitude,
              lng: customer.longitude,
              image_url: customer.image_url
            }
          }, status: :ok
        else
          render json: { errors: customer.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # POST /api/v1/customers
      def create
        @customer = Customer.new(customer_params)
        
        if @customer.save
          render json: @customer, status: :created
        else
          render json: { errors: @customer.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # 3. Get All Customers
      # GET /api/v1/customers
      def index
        customers = Customer.all
        render json: customers, status: :ok
      end

      # 4. Get Customer Details
      # GET /api/v1/customers/:id
      def show
        @customer = Customer.find(params["id"])
        render json: @customer, status: :ok
      end
 
      private
      
      def customer_location_params
        params.permit(:new_address, :lat, :lng, :image_url).transform_keys do |key| 
          case key
          when 'new_address' then 'address'
          when 'lat' then 'latitude'
          when 'lng' then 'longitude'
          else key
          end
        end
      end
      
      def customer_params
        params.permit(:name, :address, :latitude, :longitude, :user_id, :image_url)
      end
    end
  end
end
