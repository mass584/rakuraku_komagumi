require_relative 'boot'

require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'active_job/railtie'
require 'action_cable/engine'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'rails/test_unit/railtie'

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
      host: Rails.application.credentials[:action_mailer][:host],
    }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: Rails.application.credentials[:smtp][:address],
      port: 587,
      authentication: :login,
      user_name: Rails.application.credentials[:smtp][:access_key_id],
      password: Rails.application.credentials[:smtp][:secret_access_key],
    }

    # Set timezone to Japan/Tokyo
    config.time_zone = 'Tokyo'
  end
end
