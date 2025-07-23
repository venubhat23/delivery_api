module Api
  module V1
    class CustomerAddressesController < ApplicationController
      before_action :set_customer_address, only: [:show, :update, :destroy]
      
      # POST /api/v1/customer_address
      def create
        @customer_address = CustomerAddress.new(customer_address_params)
        
        if @customer_address.save
          render json: @customer_address, status: :created
        else
          render json: { errors: @customer_address.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/customer_address/:id
      def show
        render json: @customer_address, status: :ok
      end
      
      # PUT/PATCH /api/v1/customer_address/:id
      def update
        if @customer_address.update(customer_address_params)
          render json: @customer_address, status: :ok
        else
          render json: { errors: @customer_address.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/customer_address/:id (optional, not in requirements but good to have)
      def destroy
        @customer_address.destroy
        render json: { message: "Customer address deleted successfully" }, status: :ok
      end
      
      # GET /api/v1/customer_addresses (optional, to get all addresses for a customer)
      def index
        if params[:customer_id].present?
          @customer_addresses = CustomerAddress.where(customer_id: params[:customer_id])
        else
          @customer_addresses = CustomerAddress.all
        end
        
        render json: @customer_addresses, status: :ok
      end
 
      private
      
      def set_customer_address
        @customer_address = CustomerAddress.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Customer address not found" }, status: :not_found
      end
      
      def customer_address_params
        params.permit(:customer_id, :address_line, :city, :state, :postal_code, 
                      :country, :phone_number, :landmark, :full_address, 
                      :longitude, :latitude)
      end
    end
  end
end