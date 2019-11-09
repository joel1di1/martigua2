# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user_from_token!, except: :catch_404
  before_action :authenticate_user!, except: :catch_404
  before_action :set_raven_context

  helper_method :current_section, :origin_path_or

  LOCAL_REFERRER_RE = /^(https:\/\/www.martigua.org)|(https?:\/\/localhost)/.freeze

  include LogAllRequests

  def catch_404
    p "404 : #{request.url}"
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404", layout: false, status: :not_found }
      format.xml  { head :not_found }
    end
  rescue ActionController::UnknownFormat
    render file: "#{Rails.root}/public/404", layout: false, status: :not_found
  end

  protected

  def redirect_with(fallback: root_path, additionnal_params: {}, use_referrer: true, **options)
    if params[:_redirect_url].present?
      url = params[:_redirect_url].presence
      url += url['?'] ? '&' : '?'
      url += URI.encode_www_form(additionnal_params)
    else
      url = filtered_referrer if use_referrer
      url ||= fallback
    end
    redirect_to url, options
  end

  def filtered_referrer
    request.referrer if local_referrer?
  end

  def local_referrer?
    request.referrer && request.referrer[LOCAL_REFERRER_RE]
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

  def prepare_training_presences(section, users)
    last_trainings ||= Training.of_section(section).with_start_between(2.months.ago, 6.hours.from_now).last(10)
    presences = TrainingPresence.where(user: users).where(training: last_trainings)
    presences_by_user_and_training = presences.map { |pres| [[pres.user_id, pres.training_id], pres] }.to_h
    [last_trainings, presences_by_user_and_training]
  end

  private

  def set_raven_context
    Raven.user_context(id: current_user&.id, email: current_user&.email)
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def authenticate_user_from_token!
    user_email = params[:user_email].presence
    user       = user_email && User.find_by_email(user_email)

    sign_in user if user && Devise.secure_compare(user.authentication_token, params[:user_token])
  end
end
