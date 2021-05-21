module Optimization
  class OptimizationController < ApplicationController
    include ErrorResponse
    skip_before_action :verify_authenticity_token
    rescue_from Exception, with: :handle_internal_server_error
    before_action :basic_auth

    private

    def basic_auth
      username = Rails.application.credentials[:basic_auth][:username]
      password = Rails.application.credentials[:basic_auth][:password]
      authenticate_or_request_with_http_basic do |username_in_query, password_in_query|
        username == username_in_query && password == password_in_query
      end
    end

    def handle_internal_server_error(exception = nil)
      logger.info "500 response with exception: #{exception.message}" if exception
      puts "500 response with exception: #{exception.message}" if exception && Rails.env.test?
      render json: internal_server_error, status: 500
    end
  end
end
