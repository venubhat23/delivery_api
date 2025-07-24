class ApplicationController < ActionController::Base
  include ApiErrorHandling
  
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request, except: [:api_not_found]
  
  # Add error handling for API requests
  rescue_from StandardError, with: :handle_server_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActionController::RoutingError, with: :handle_not_found
  rescue_from ActionController::ParameterMissing, with: :handle_bad_request
  
  attr_reader :current_user
  
  private
  
  def authenticate_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    
    begin
      @decoded = JsonWebToken.decode(header)
      if @decoded.present?
        if @decoded[:user_id].present?
          @current_user = User.find(@decoded[:user_id])
        elsif @decoded[:customer_id].present?
          @current_user = Customer.find(@decoded[:customer_id])
        end
      else
        render json: { errors: "Token is expired or invalid" }, status: :unauthorized
      end
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end
  
  def handle_server_error(exception)
    Rails.logger.error "Server Error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    
    render json: { 
      error: "Internal server error", 
      message: Rails.env.development? ? exception.message : "Something went wrong" 
    }, status: :internal_server_error
  end
  
  def handle_not_found(exception)
    render json: { 
      error: "Not found", 
      message: exception.message 
    }, status: :not_found
  end
  
  def handle_bad_request(exception)
    render json: { 
      error: "Bad request", 
      message: exception.message 
    }, status: :bad_request
  end
  
  def api_not_found
    render json: { 
      error: "Not found", 
      message: "The requested API endpoint does not exist" 
    }, status: :not_found
  end
end
