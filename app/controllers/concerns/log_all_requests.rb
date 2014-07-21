module LogAllRequests extend ActiveSupport::Concern
  included do
    around_filter :log_requests
  end

  def log_requests(&block)
    if Rails.env.test?
      yield
    else
      begin
        yield
        p "#{request_string} --RESP-- #{response.status};#{response.redirect_url}" 
      rescue Exception => ex
        p "#{request_string} --RESP-- 500;#{ex.message};#{ex.backtrace}"
        raise
      end
    end
  end

  def request_string
    "--REQ-- #{Rails.env};#{current_user.try(:id)};#{current_user.try(:email)};#{request.method};#{request.url};#{request.host};#{request.query_string};#{filter_params(params)}"
  end

  def filter_params params
    filters = Rails.application.config.filter_parameters
    f = ActionDispatch::Http::ParameterFilter.new filters
    f.filter params
  end

end