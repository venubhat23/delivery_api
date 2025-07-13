# Configure Rails to return JSON error responses for API requests
Rails.application.configure do
  # Override the default exception handling for API requests
  config.exceptions_app = ->(env) {
    # Check if this is an API request
    request = ActionDispatch::Request.new(env)
    
    if request.path.start_with?('/api/') || request.headers['Content-Type']&.include?('application/json')
      # Return JSON error response
      status = env['PATH_INFO'][1..-1].to_i
      
      case status
      when 404
        message = "Endpoint not found"
      when 500
        message = "Internal server error"
      when 422
        message = "Unprocessable entity"
      when 401
        message = "Unauthorized"
      when 403
        message = "Forbidden"
      else
        message = "An error occurred"
      end
      
      [
        status,
        { 'Content-Type' => 'application/json' },
        [
          {
            error: message,
            status: status,
            path: request.path,
            method: request.request_method
          }.to_json
        ]
      ]
    else
      # Use default Rails error handling for non-API requests
      ActionDispatch::PublicExceptions.new(Rails.public_path).call(env)
    end
  }
end

# Additional configuration for API error handling
module ApiErrorHandler
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def handle_api_errors
      rescue_from StandardError do |exception|
        handle_standard_error(exception)
      end
      
      rescue_from ActiveRecord::RecordNotFound do |exception|
        handle_record_not_found(exception)
      end
      
      rescue_from ActiveRecord::RecordInvalid do |exception|
        handle_record_invalid(exception)
      end
    end
  end
  
  private
  
  def render_json_error(message, status = :internal_server_error, details = nil)
    error_response = {
      error: message,
      status: Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
    }
    
    error_response[:details] = details if details
    error_response[:timestamp] = Time.current.iso8601
    
    render json: error_response, status: status
  end
end