module Api
  module V1
    class AuthenticationController < ApplicationController
      skip_before_action :authenticate_request, only: [:login, :signup, :customer_login, :regenerate_token]

      # POST /api/v1/login
      def login
        if params[:role] == 'customer'
          customer_login
        else
          # For admin and delivery_person
          @user = User.find_by(phone: params[:phone])
          
          if @user&.authenticate(params[:password]) && %w[admin delivery_person].include?(@user.role)
            token = JsonWebToken.encode(user_id: @user.id)
            render json: { 
              token: token, 
              user: { 
                id: @user.id, 
                name: @user.name, 
                role: @user.role,
                email: @user.email,
                phone: @user.phone
              } 
            }, status: :ok
          else
            render json: { error: 'Invalid credentials' }, status: :unauthorized
          end
        end
      end

      # POST /api/v1/customer_login
      def customer_login
        @customer = Customer.find_by(phone_number: params[:phone])
        
        if @customer&.authenticate(params[:password]) && @customer.is_active?
          token = JsonWebToken.encode(customer_id: @customer.id)
          render json: { 
            token: token, 
            customer: {
              id: @customer.id,
              name: @customer.name,
              address: @customer.address,
              phone_number: @customer.phone_number,
              email: @customer.email,
              preferred_language: @customer.preferred_language,
              delivery_time_preference: @customer.delivery_time_preference,
              notification_method: @customer.notification_method
            }
          }, status: :ok
        else
          render json: { error: 'Invalid credentials or account inactive' }, status: :unauthorized
        end
      end


      # POST /api/v1/signup
      def signup
        if params[:role] == "customer"
          @user1 = User.first
          @user = Customer.new(customer_params.merge(user: @user1))
        else
          @user = User.new(user_params)
        end
        if @user.save
          # If role is customer, create customer record
          if params[:role] == "customer"
              @customer = @user
              token = JsonWebToken.encode(customer_id: @user.id)

              render json: { 
                token: token,
                customer: {
                  id: @customer.id,
                  name: @customer.name,
                  address: @customer.address,
                  phone_number: @customer.phone_number,
                  email: @customer.email,
                  latitude: @customer.latitude,
                  longitude: @customer.longitude
                }
              }, status: :created
          else
            # For admin and delivery_person roles
            token = JsonWebToken.encode(user_id: @user.id)
            render json: { 
              token: token, 
              user: { 
                id: @user.id, 
                name: @user.name, 
                role: @user.role,
                email: @user.email,
                phone: @user.phone
              } 
            }, status: :created
          end
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/regenerate_token
      def regenerate_token
        debugger

        if params[:role] == 'customer'
          customer_login
        else
          # For admin and delivery_person
          @user = User.find_by(phone: params[:phone])
          
          if @user&.authenticate(params[:password]) && %w[admin delivery_person].include?(@user.role)
            token = JsonWebToken.encode(user_id: @user.id)
            render json: { 
              token: token, 
              user: { 
                id: @user.id, 
                name: @user.name, 
                role: @user.role,
                email: @user.email,
                phone: @user.phone
              } 
            }, status: :ok
          else
            render json: { error: 'Invalid credentials' }, status: :unauthorized
          end
        end

      end

      private

      def user_params
        params.permit(:name, :email, :phone, :password, :role)
      end

      def customer_params
        params.permit(:name,:password, :address, :phone_number, :email, :latitude, :longitude, 
                     :preferred_language, :delivery_time_preference, :notification_method, 
                     :address_type, :address_landmark, :alt_phone_number)
      end
    end
  end
end
