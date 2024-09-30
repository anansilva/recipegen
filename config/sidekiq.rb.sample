if Rails.env.production?
  sidekiq_config = { url: Rails.application.credentials.dig(:jobs, :url) }
else
  sidekiq_config = { url: 'redis://redis:6379/0' }
end

Sidekiq.configure_server do |config|
    config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
    config.redis = sidekiq_config
end
