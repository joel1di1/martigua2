class SmsNotificationsController < ApplicationController

  def new
    @sms_notification = SmsNotification.new(params[:sms_notification] ? sms_notification_params : nil)
    @last_sms = SmsNotification.order('created_at DESC').limit(5)
  end

  def create 
    sms_notification = SmsNotification.new(sms_notification_params)
    sms_notification.section = current_section
    sms_notification.save!

    redirect_to new_section_sms_notification_path(current_section), notice: "SMS envoyé !!"
  end

  private
    def sms_notification_params
      params.require(:sms_notification).permit(:title, :description, :section_id)
    end
end

