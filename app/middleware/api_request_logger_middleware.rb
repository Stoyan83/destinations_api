class ApiRequestLoggerMiddleware
    LOGGED_METHODS = %w[POST PUT PATCH DELETE].freeze
  
    def initialize(app)
      @app = app
    end
  
    def call(env)
      start_time = Time.now
      request = Rack::Request.new(env)
  
      log_request = LOGGED_METHODS.include?(request.request_method)
  
      json_params = {}
      if request.media_type == 'application/json' && request.body
        begin
          request.body.rewind
          json_params = JSON.parse(request.body.read)
          request.body.rewind
        rescue JSON::ParserError
          json_params = {}
        end
      end
  
      all_params = request.params.merge(json_params)
  
      status, headers, response = @app.call(env)
  
      if log_request
        ::ApiRequestLoggerWorker.perform_async(
          "http_method"     => request.request_method,
          "path"            => request.fullpath,
          "params"          => all_params.as_json,
          "response_status" => status,
          "ip"              => request.ip,
          "duration_ms"     => ((Time.now - start_time) * 1000).round(2)
        )
      end
  
      [status, headers, response]
    rescue => e
      Rails.logger.error("[ApiRequestLoggerMiddleware] #{e.class}: #{e.message}")
      raise e
    end
  end
  