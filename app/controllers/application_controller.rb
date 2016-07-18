class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:locale, :name, :email])
    # devise_parameter_sanitizer.permit(:sign_in, keys: [:locale]) n/n
    devise_parameter_sanitizer.permit(:account_update, keys: [:locale, :name, :email])
  end
  
  private

  # set the language
  def set_locale
    I18n.locale = current_user.try(:locale) || extract_locale_from_accept_language_header
  end

  def extract_locale_from_accept_language_header
    logger.info '.. from header' 
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end  
  # I18n.default_locale
end
