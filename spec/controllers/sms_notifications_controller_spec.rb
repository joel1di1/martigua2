require "rails_helper"

describe SmsNotificationsController, :type => :controller do

  let(:section) { create :section}
  let(:sms_notification) { create :sms_notification, section: section }
  let(:user) { create :user, with_section: section }

  describe "GET new" do
    let(:do_request) { get :new, section_id: section.to_param, user_email: user.email, user_token: user.authentication_token }

    before { do_request }
    
    it { expect(response).to have_http_status(:success) }
  end

  describe "POST create" do
    let(:sms_notification_attributes) { attributes_for(:sms_notification, section: nil) }

    let(:auth_params) { {section_id: section.to_param, user_email: user.email, user_token: user.authentication_token, format: :json } }
    let(:req_params) { auth_params.merge({sms_notification: sms_notification_attributes}) }

    let(:do_request) { post :create, req_params }

    before{ allow(Blower).to receive(:send_sms) } 

    it "should respond success" do
      do_request
      expect(response).to redirect_to(new_section_sms_notification_path(section))
    end

    it "should create a new SMS notification" do 
      expect{do_request}.to change{SmsNotification.count}

      expect(SmsNotification.last.title).to eq sms_notification.title
      expect(SmsNotification.last.description).to eq sms_notification.description
      expect(SmsNotification.last.section).to eq section
    end
  end

end
