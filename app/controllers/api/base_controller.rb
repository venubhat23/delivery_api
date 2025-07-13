module Api
  class BaseController < ApplicationController
    # Skip CSRF protection for API endpoints
    skip_before_action :verify_authenticity_token
    
    # Override respond_to to default to JSON
    respond_to :json
    
    # Additional API-specific exception handlers
    rescue_from ActionController::RoutingError, with: :handle_routing_error
    rescue_from ActionController::UnknownFormat, with: :handle_unknown_format
    rescue_from ActionController::InvalidAuthenticityToken, with: :handle_invalid_token
    
    private
    
    # Override the parent's error handlers to provide more API-specific responses
    def handle_standard_error(exception)
      Rails.logger.error "API Error: #{exception.class.name} - #{exception.message}"
      Rails.logger.error exception.backtrace.join("\n") if Rails.env.development?
      
      render json: {
        error: "Internal server error",
        message: Rails.env.development? ? exception.message : "Something went wrong",
        type: exception.class.name,
        timestamp: Time.current.iso8601
      }, status: :internal_server_error
    end
    
    def handle_record_not_found(exception)
      render json: {
        error: "Resource not found",
        message: exception.message,
        type: "RecordNotFound",
        timestamp: Time.current.iso8601
      }, status: :not_found
    end
    
    def handle_record_invalid(exception)
      render json: {
        error: "Validation failed",
        message: exception.message,
        errors: exception.record.errors.full_messages,
        type: "ValidationError",
        timestamp: Time.current.iso8601
      }, status: :unprocessable_entity
    end
    
    def handle_routing_error(exception)
      render json: {
        error: "Endpoint not found",
        message: exception.message,
        type: "RoutingError",
        timestamp: Time.current.iso8601
      }, status: :not_found
    end
    
    def handle_unknown_format(exception)
      render json: {
        error: "Unsupported format",
        message: "This endpoint only supports JSON format",
        type: "UnknownFormat",
        timestamp: Time.current.iso8601
      }, status: :not_acceptable
    end
    
    def handle_invalid_token(exception)
      render json: {
        error: "Invalid authentication token",
        message: exception.message,
        type: "InvalidToken",
        timestamp: Time.current.iso8601
      }, status: :unauthorized
    end
    
    # Helper method for consistent success responses
    def render_success(data = {}, message = "Success", status = :ok)
      render json: {
        success: true,
        message: message,
        data: data,
        timestamp: Time.current.iso8601
      }, status: status
    end
    
    # Helper method for consistent error responses
    def render_error(message, status = :bad_request, details = nil)
      error_response = {
        error: message,
        success: false,
        timestamp: Time.current.iso8601
      }
      
      error_response[:details] = details if details
      
      render json: error_response, status: status
    end
    
    # Helper method for validation errors
    def render_validation_errors(model)
      render json: {
        error: "Validation failed",
        success: false,
        errors: model.errors.full_messages,
        field_errors: model.errors.messages,
        timestamp: Time.current.iso8601
      }, status: :unprocessable_entity
    end
  end
end