# frozen_string_literal: true

class ApplicationController < ActionController::Base
  around_action :log_requests

  before_action :set_sentry_context
  before_action :set_current_user_in_current
  before_action :set_current_section_in_current
  before_action :authenticate_user_from_token!, except: :catch404
  before_action :authenticate_user!, except: :catch404
  before_action :verify_user_member_of_section, except: :catch404

  helper_method :current_section, :origin_path_or

  LOCAL_REFERRER_RE = %r{^(https://www.martigua.org)|(https?://localhost)}

  def catch404
    Rails.logger.debug { "404 : #{request.url}" }
    respond_to do |format|
      format.html { render file: Rails.public_path.join('404.html'), layout: false, status: :not_found }
      format.xml  { head :not_found }
      format.json { head :not_found }
      format.js   { head :not_found }
    end
  rescue ActionController::UnknownFormat
    render file: Rails.public_path.join('404'), layout: false, status: :not_found
  end

  protected

  def log_requests
    yield
    log_success
  rescue StandardError => e
    log_error(e)
    raise
  end

  def log_success
    Rails.logger.info("#{request_string}--RESP--;#{response.status};#{response.redirect_url}") unless Rails.env.test?
  end

  def log_error(exception)
    return if Rails.env.test?

    Rails.logger.info("#{request_string}--RESP--;5xx;#{exception.message};#{exception.backtrace}")
  end

  def request_string
    "--REQ--;#{Rails.env};#{current_user&.id};#{current_user&.email};#{request.method};#{filtered_url};#{request.host};#{filtered_query_string};#{filter_params(params)};"
  end

  def filter_params(params)
    filters = Rails.application.config.filter_parameters
    f = ActiveSupport::ParameterFilter.new filters
    f.filter params
  end

  def filtered_query_string
    filter_params(request.GET).to_query
  end

  def filtered_url
    request.query_string.blank? ? request.url : "#{request.base_url}#{request.path}?#{filtered_query_string}"
  end

  def redirect_with(fallback: root_path, additionnal_params: {}, use_referrer: true, **options)
    url = construct_url(additionnal_params, use_referrer, fallback)
    redirect_to url, options
  end

  def construct_url(additionnal_params, use_referrer, fallback)
    if params[:_redirect_url].present?
      construct_url_with_redirect_url(additionnal_params)
    else
      construct_url_with_referrer_and_fallback(use_referrer, fallback)
    end
  end

  def construct_url_with_redirect_url(additionnal_params)
    url = params[:_redirect_url].presence
    url += url['?'] ? '&' : '?'
    url + URI.encode_www_form(additionnal_params)
  end

  def construct_url_with_referrer_and_fallback(use_referrer, fallback)
    url = filtered_referrer if use_referrer
    url || fallback
  end

  def filtered_referrer
    request.referer if local_referrer?
  end

  def local_referrer?
    request.referer && request.referer[LOCAL_REFERRER_RE]
  end

  def current_section
    @current_section ||= current_section_from_params
  end

  def current_section_from_params
    section_id = section_id_from_params_id || params[:section_id]
    section_id ? Section.find(section_id) : nil
  end

  def section_id_from_params_id
    params[:id] if params[:controller] == 'sections' && params[:id]
  end

  def prepare_training_presences(section, users)
    last_trainings ||= Training.not_cancelled.of_section(section).with_start_between(2.months.ago,
                                                                                     6.hours.from_now).last(10)
    presences = TrainingPresence.where(user: users).where(training: last_trainings)
    presences_by_user_and_training = presences.index_by { |pres| [pres.user_id, pres.training_id] }
    [last_trainings, presences_by_user_and_training]
  end

  def verify_user_member_of_section
    return if current_section.blank?
    return if current_user&.member_of?(current_section)
    return if current_user&.admin_of?(current_section.club)
    return if current_user&.super_admin?

    respond_to do |format|
      format.html { render(file: Rails.public_path.join('403.html'), status: :forbidden, layout: false) }
      format.xml  { head :forbidden }
      format.json { head :forbidden }
      format.js { head :forbidden }
    end
  end

  # Raises 404 (via catch404) when a record loaded by id does not belong to
  # current_section, even though the user is a member of current_section.
  def verify_section_ownership!(association, id:)
    return if current_section.blank?
    return if current_section.public_send(association).exists?(id)

    raise ActiveRecord::RecordNotFound
  end

  # Days aren't owned by a single section (they belong to a season-wide calendar), so
  # ownership is derived from having at least one match in current_section's championships.
  def verify_day_ownership!(day)
    return if current_section.blank?
    return if day.matches.exists?(championship: current_section.championships)

    raise ActiveRecord::RecordNotFound
  end

  private

  def set_sentry_context
    Sentry.set_user(id: current_user&.id, email: current_user&.email)
  end

  def authenticate_user_from_token!
    token = params[:user_token].presence
    user  = token && User.find_by_token_for(:email_authentication, token)

    sign_in user if user
  end

  def set_current_user_in_current
    Current.user = current_user
  end

  def set_current_section_in_current
    Current.section = current_section
  end
end
