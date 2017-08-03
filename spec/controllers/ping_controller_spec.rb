require "rails_helper"

describe PingController do
  describe "GET index" do
    subject { get :index }
    context 'not signed in' do
      it { expect(response.status).to eq(200) }
      describe 'response' do
        before { get :index }
        subject { JSON.parse(response.body) }
        it { should include('datetime') }
        it { should_not include('current_user') }
      end
    end
    context 'sign as user with tokens' do
      let(:user) { create :user }
      it { expect(response.status).to eq(200) }
      describe 'response' do
        before { get :index, params: { user_email: user.email, user_token: user.authentication_token } }
        subject { JSON.parse(response.body) }
        it { should include('datetime') }
        it { should include('current_user') }
      end
    end
  end
end