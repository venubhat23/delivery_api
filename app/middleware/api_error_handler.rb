class ApiErrorHandler
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    
    # Only handle API requests
    if request.path.start_with?('/api/')
      begin
        status, headers, response = @app.call(env)
        
        # Check if it's an error response and contains HTML
        if is_error_status?(status) && contains_html?(response)
          # Return JSON error instead
          json_response = {
            error: get_error_message(status),
            message: get_error_description(status, request.path)
          }.to_json
          
          return [status, { 'Content-Type' => 'application/json' }, [json_response]]
        end
        
        [status, headers, response]
      rescue => e
        # Handle any unhandled exceptions
        Rails.logger.error "API Error: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        
        json_response = {
          error: "Internal server error",
          message: Rails.env.development? ? e.message : "Something went wrong"
        }.to_json
        
        [500, { 'Content-Type' => 'application/json' }, [json_response]]
      end
    else
      @app.call(env)
    end
  end

  private

  def is_error_status?(status)
    status >= 400
  end

  def contains_html?(response)
    response_body = ""
    if response.respond_to?(:each)
      response.each { |part| response_body += part.to_s }
    else
      response_body = response.to_s
    end
    
    response_body.include?('<!DOCTYPE html') || response_body.include?('<html')
  end

  def get_error_message(status)
    case status
    when 404
      "Not found"
    when 401
      "Unauthorized"
    when 403
      "Forbidden"
    when 422
      "Unprocessable entity"
    when 500
      "Internal server error"
    else
      "Error"
    end
  end

  def get_error_description(status, path)
    case status
    when 404
      if path.include?('/deliveries/') && path.include?('/compl')
        "The requested delivery endpoint does not exist. Use 'complete' instead of 'compl'."
      else
        "The requested API endpoint does not exist"
      end
    when 401
      "Authentication required"
    when 403
      "Access forbidden"
    when 422
      "Request could not be processed"
    when 500
      "Internal server error occurred"
    else
      "An error occurred"
    end
  end
end