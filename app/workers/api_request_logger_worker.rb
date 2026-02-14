class ApiRequestLoggerWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default, retry: 3

  def perform(attrs)
    ApiRequest.create!(
      http_method: attrs["http_method"],
      path: attrs["path"],
      params: attrs["params"],
      response_status: attrs["response_status"],
      ip_address: attrs["ip"],
      duration_ms: attrs["duration_ms"],
      created_at: Time.current
    )
  rescue StandardError => e
    Rails.logger.error("[ApiRequestLoggerWorker] Failed to log API request: #{e.message}")
    raise e
  end
end
