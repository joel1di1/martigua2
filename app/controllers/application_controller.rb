class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  around_filter :log_requests

  def log_requests(&block)
    request_string = "--REQ-- #{Rails.env};#{current_user.try(:id)};#{current_user.try(:email)};#{request.url};#{request.host};#{request.query_string};#{filter_params(params)}"
    begin
      yield
      p "#{request_string}\n--RESP-- #{response.status};#{response.redirect_url}" unless Rails.env.test?
    rescue Exception => ex
      p "#{request_string}\n--RESP-- 500;#{ex.message};#{ex.backtrace}" unless Rails.env.test?
      raise
    end
  end


end
