class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  around_filter :user_time_zone, if: :current_user

  private

  # adjust to users timezone
  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  # Sanitize devise permitted parameters
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:locale, :name, :email])
    # devise_parameter_sanitizer.permit(:sign_in, keys: [:locale]) n/n
    devise_parameter_sanitizer.permit(:account_update, keys: [:locale, :name, :email])
    # logger.info "INFO: did > configure_permitted_parameters"
  end
  
  # Set the language
  def set_locale
    I18n.locale = current_user.try(:locale) || extract_locale_from_accept_language_header
  end
  
  # Extract language from HHTP-header
  def extract_locale_from_accept_language_header
    lang = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    logger.info "INFO: Language #{lang} determined from header"
    lang
  end  
  # I18n.default_locale
  
end
