Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.cache_store = :memory_store
  config.force_ssl = true
  config.public_file_server.enabled = ENV.fetch("RAILS_SERVE_STATIC_FILES", "true") == "true"
  config.assets.compile = false
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.log_tags = [:request_id]
  config.active_storage.service = ENV["S3_BUCKET"].present? ? :amazon : :local
  config.active_job.queue_adapter = :inline
  config.action_mailer.default_url_options = { host: ENV["APP_HOST"], protocol: "https" }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = ENV["SMTP_HOST"].present?
  config.action_mailer.smtp_settings = {
    address: ENV["SMTP_HOST"], port: ENV.fetch("SMTP_PORT", "587").to_i,
    user_name: ENV["SMTP_USER"], password: ENV["SMTP_PASSWORD"],
    authentication: ENV["SMTP_USER"].present? ? :plain : nil, enable_starttls: true
  }
end
