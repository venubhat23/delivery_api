class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request
  
  # Global exception handlers to ensure all errors return JSON
  rescue_from StandardError, with: :handle_standard_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
  rescue_from ActiveRecord::RecordNotUnique, with: :handle_record_not_unique
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from ActionController::UnpermittedParameters, with: :handle_unpermitted_parameters
  rescue_from JWT::DecodeError, with: :handle_jwt_decode_error
  rescue_from JSON::ParserError, with: :handle_json_parser_error
  
  attr_reader :current_user
  
  private
  
  def authenticate_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    
    begin
      @decoded = JsonWebToken.decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end
  
  # Exception handlers
  def handle_standard_error(exception)
    Rails.logger.error "StandardError: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    
    render json: { 
      error: "Internal server error", 
      message: Rails.env.development? ? exception.message : "Something went wrong"
    }, status: :internal_server_error
  end
  
  def handle_record_not_found(exception)
    render json: { 
      error: "Record not found", 
      message: exception.message 
    }, status: :not_found
  end
  
  def handle_record_invalid(exception)
    render json: { 
      error: "Validation failed", 
      message: exception.message,
      errors: exception.record.errors.full_messages 
    }, status: :unprocessable_entity
  end
  
  def handle_record_not_unique(exception)
    render json: { 
      error: "Record already exists", 
      message: exception.message 
    }, status: :conflict
  end
  
  def handle_parameter_missing(exception)
    render json: { 
      error: "Missing required parameter", 
      message: exception.message 
    }, status: :bad_request
  end
  
  def handle_unpermitted_parameters(exception)
    render json: { 
      error: "Unpermitted parameters", 
      message: exception.message 
    }, status: :bad_request
  end
  
  def handle_jwt_decode_error(exception)
    render json: { 
      error: "Invalid token", 
      message: exception.message 
    }, status: :unauthorized
  end
  
  def handle_json_parser_error(exception)
    render json: { 
      error: "Invalid JSON format", 
      message: exception.message 
    }, status: :bad_request
  end
end
