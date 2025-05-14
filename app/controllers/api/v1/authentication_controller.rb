module Api
  module V1
    class AuthenticationController < ApplicationController
      skip_before_action :authenticate_request, only: [:login, :signup]

      # POST /api/v1/login
      def login
        @user = User.find_by(phone: params[:phone])
        
        if @user&.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: @user.id)
          render json: { token: token, user: { id: @user.id, name: @user.name, role: @user.role } }, status: :ok
        else
          render json: { error: 'Invalid credentials' }, status: :unauthorized
        end
      end

      # POST /api/v1/signup
      def signup
          debugger   # This will pause execution here

        @user = User.new(user_params)
        
        if @user.save
          token = JsonWebToken.encode(user_id: @user.id)
          render json: { token: token, user: { id: @user.id, name: @user.name, role: @user.role } }, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(:name, :email, :phone, :password, :role)
      end
    end
  end
end
