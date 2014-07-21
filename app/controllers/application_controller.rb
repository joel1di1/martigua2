class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_user_from_token!
  before_filter :authenticate_user!

  helper_method :current_section

  include LogAllRequests

  protected 
    def current_section
      @current_section ||= current_section_from_params
    end

    def current_section_from_params
      section_id = get_section_id_from_params_id
      section_id ||= get_section_id_from_params_section_id
      section_id ? Section.find(section_id) : nil
    end

    def get_section_id_from_params_id
      params[:id] if params[:controller] == 'sections' && params[:id]
    end

    def get_section_id_from_params_section_id
      params[:section_id] if params[:section_id]
    end

  private
    
    def authenticate_user_from_token!
      user_email = params[:user_email].presence
      user       = user_email && User.find_by_email(user_email)
   
      # Notice how we use Devise.secure_compare to compare the token
      # in the database with the token given in the params, mitigating
      # timing attacks.
      if user && Devise.secure_compare(user.authentication_token, params[:user_token])
        sign_in user, store: false
      end
    end
end
