require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RakurakuKomagumi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Translate ActiveModel validation error message to Japanese (gem 'rails-i18n' is needed)
    config.i18n.default_locale = :ja
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', 'ja.yml').to_s]

    # ActiveJob
    config.active_job.queue_adapter = :delayed_job
    config.active_job.queue_name_prefix = Rails.env

    # ActionMailer
    config.action_mailer.default_url_options = {
      host: 'localhost',
      port: 8000,
    }
    config.action_mailer.delivery_method = :smtp
    #config.action_mailer.smtp_settings = {
    #  address: Rails.application.credentials[:smtp][:address],
    #  port: Rails.application.credentials[:smtp][:port],
    #  user_name: Rails.application.credentials[:smtp][:username],
    #  password: Rails.application.credentials[:smtp][:password],
    #  authentication: :plain,
    #  enable_starttls_auto: true,
    #}

    # Set timezone to Japan/Tokyo
    config.time_zone = 'Tokyo'
  end
end
