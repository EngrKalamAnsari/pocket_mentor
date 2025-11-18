class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  rescue_from ActionController::InvalidAuthenticityToken, with: :handle_invalid_auth_token
  rescue_from CanCan::AccessDenied, with: :handle_access_denied
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  rescue_from StandardError, with: :handle_standard_error unless Rails.env.development? || Rails.env.test?

  def route_not_found
    redirect_to root_path, alert: 'The requested page was not found.'
  end

  private

  def handle_invalid_auth_token
    reset_session
    redirect_to root_path, alert: 'Your session has expired. Please try again.'
  end

  def handle_access_denied(exception)
    redirect_to root_path, alert: exception.message
  end

  def handle_record_not_found
    redirect_to root_path, alert: 'The requested resource was not found.'
  end

  def handle_standard_error(exception)
    logger.error exception.message
    logger.error exception.backtrace.join("\n")
    redirect_to root_path, alert: 'An unexpected error occurred. Please try again later.'
  end
end
