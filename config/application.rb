require_relative "boot"

%w[rails active_model/railtie active_job/railtie active_record/railtie
   active_storage/engine action_controller/railtie action_mailer/railtie
   action_view/railtie rails/test_unit/railtie].each { |component| require component }

Bundler.require(*Rails.groups)

module DelivMyApp
  class Application < Rails::Application
    config.load_defaults 8.1
    config.time_zone = "Central Time (US & Canada)"
    config.active_job.queue_adapter = :async
    config.active_storage.analyzers = []
    config.active_storage.track_variants = false
    config.action_dispatch.show_exceptions = :rescuable
    config.action_controller.forgery_protection_origin_check = true
    config.action_dispatch.default_headers["Referrer-Policy"] = "same-origin"
    config.action_controller.wrap_parameters_by_default = false
    # The committed schema is portable; avoid replacing MySQL bigint definitions with SQLite aliases.
    config.active_record.dump_schema_after_migration = false
    config.middleware.use Rack::Attack
  end
end
