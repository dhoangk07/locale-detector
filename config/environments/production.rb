Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.assets.js_compressor = :uglifier
  config.assets.compile = false
  config.active_storage.service = :local
  config.log_level = :debug
  config.log_tags = [ :request_id ]
  config.action_mailer.perform_caching = false
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end
  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Add notify to Slack when app get error
  Rails.application.config.middleware.use ExceptionNotification::Rack,
  :slack => {
    :webhook_url => "https://hooks.slack.com/services/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",
    :channel => "#locale-detetor",
    :additional_parameters => {
      :icon_url => "https://unsplash.com/photos/reZbvcVASPI",
      :mrkdwn => true
    }
  }

  # Config Mailgun
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :authentication => :plain,
    :address => "smtp.mailgun.org",
    :port => 587,
    :domain => Rails.application.secrets[:DOMAIN],
    :user_name => Rails.application.secrets[:MYUSERNAME],
    :password => Rails.application.secrets[:MYPASSWORD]
  }
end
