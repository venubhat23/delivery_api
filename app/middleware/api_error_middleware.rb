class ApiErrorMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    
    # Only apply this middleware to API requests
    return @app.call(env) unless api_request?(request)
    
    begin
      status, headers, response = @app.call(env)
      
      # If the response is HTML but this is an API request, convert to JSON
      if html_response?(headers) && api_request?(request)
        json_response = convert_to_json_error(status, request)
        headers['Content-Type'] = 'application/json'
        response = [json_response]
      end
      
      [status, headers, response]
    rescue Exception => e
      # Last resort: catch any unhandled exceptions and return JSON
      Rails.logger.error "Unhandled exception in API: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      json_error = {
        error: "Internal server error",
        message: Rails.env.development? ? e.message : "Something went wrong",
        type: e.class.name,
        timestamp: Time.current.iso8601
      }.to_json
      
      [500, { 'Content-Type' => 'application/json' }, [json_error]]
    end
  end

  private

  def api_request?(request)
    request.path.start_with?('/api/') || 
    request.env['HTTP_ACCEPT']&.include?('application/json') ||
    request.env['CONTENT_TYPE']&.include?('application/json')
  end

  def html_response?(headers)
    headers['Content-Type']&.include?('text/html')
  end

  def convert_to_json_error(status, request)
    message = case status
              when 404
                "Endpoint not found"
              when 500
                "Internal server error"
              when 422
                "Unprocessable entity"
              when 401
                "Unauthorized"
              when 403
                "Forbidden"
              else
                "An error occurred"
              end

    {
      error: message,
      status: status,
      path: request.path,
      method: request.request_method,
      timestamp: Time.current.iso8601
    }.to_json
  end
end