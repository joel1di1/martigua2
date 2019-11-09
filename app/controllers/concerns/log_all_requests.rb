# frozen_string_literal: true

module LogAllRequests
  extend ActiveSupport::Concern
  included do
    around_action :log_requests
  end

  def log_requests
    yield
    log_if_active "#{request_string} --RESP-- #{response.status};#{response.redirect_url}"
  rescue Exception => e
    log_if_active "#{request_string} --RESP-- 500;#{e.message};#{e.backtrace}"
    raise
  end

  def log_if_active(str)
    puts str if log_active?
  end

  def log_active?
    !Rails.env.test?
  end

  def request_string
    "--REQ-- #{Rails.env};#{current_user.try(:id)};#{current_user.try(:email)};#{request.method};#{request.url};#{request.host};#{request.query_string};#{filter_params(params)}"
  end

  def filter_params(params)
    filters = Rails.application.config.filter_parameters
    f = ActiveSupport::ParameterFilter.new filters
    f.filter params
  end
end
