class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user_from_token!, except: :catch_404
  before_action :authenticate_user!, except: :catch_404

  helper_method :current_section, :origin_path_or

  helper Starburst::AnnouncementsHelper

  include LogAllRequests

  def catch_404
    p "404 : #{request.url}"
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
      format.xml  { head :not_found }
    end
  end

  protected

    def referer_url_or(default_path)
      referrer = request.referrer
      if referrer &&
         referrer.match(Rails.application.config.action_mailer.default_url_options[:host])
        referrer
      else
        default_path
      end
    end

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

      if user && Devise.secure_compare(user.authentication_token, params[:user_token])
        sign_in user
      end
    end
end
