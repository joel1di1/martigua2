class PingController < ApplicationController

  def index 
    json = { datetime: Time.now.getutc }
    json[:current_user] = { email: current_user.email } if user_signed_in?
    render json: json
  end
end