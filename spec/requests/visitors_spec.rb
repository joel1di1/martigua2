# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Visitors', type: :request do
  describe 'GET /' do
    context 'when not signed in' do
      before { get '/' }

      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to render_template('index') }
    end

    context 'when sign as user with only one section' do
      let(:user) { create(:one_section_player) }

      before do
        sign_in user, scope: :user
        get '/'
      end

      it { expect(response).to redirect_to(section_path(user.sections.first)) }
    end
  end
end
