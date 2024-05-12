# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController do
  controller(ApplicationController) do
    skip_before_action :authenticate_user!

    def index
      raise 'TEST ERROR' if params[:error]

      render plain: 'Hello, world!'
    end
  end

  describe '#log_requests' do
    context 'when not in test env' do
      before { allow(Rails.env).to receive(:test?).and_return(false) }

      it 'logs the request and response' do
        expect(Rails.logger).to receive(:info).with(/REQ/)
        expect(Rails.logger).to receive(:info).at_least(:once)
        get :index

        # assert response
        expect(response).to have_http_status(:success)
      end

      it 'logs an error if one occurs' do
        expect(Rails.logger).to receive(:info).with(/REQ/)
        expect(Rails.logger).to receive(:info).at_least(:once)

        expect { get(:index, params: { error: true }) }.to raise_error(RuntimeError, 'TEST ERROR')
      end
    end

    context 'when in test env' do
      before { allow(Rails.env).to receive(:test?).and_return(true) }

      it 'does not log' do
        allow(Rails.env).to receive(:test?).and_return(true)
        expect(Rails.logger).not_to receive(:info).with(/REQ/)
        get :index
      end
    end
  end
end
