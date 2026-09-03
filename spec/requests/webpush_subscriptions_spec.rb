# frozen_string_literal: true

require 'rails_helper'

# WebpushSubscriptionsController#create relies on ActionController::ParamsWrapper:
# app/javascript/webpush.js posts a *flat* JSON body while the controller reads
# params.expect(webpush_subscription: ...). Wrapping is enabled by
# `config.load_defaults 8.0` (wrap_parameters_by_default). If it is ever turned
# off, this spec fails instead of silently dropping every subscription.
describe 'WebpushSubscriptions' do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section: section) }
  let(:json_headers) { { 'CONTENT_TYPE' => 'application/json' } }
  let(:subscription_payload) do
    { endpoint: 'https://push.example.com/abc', p256dh_key: 'p256dh', auth_key: 'auth' }
  end

  before { sign_in user, scope: :user }

  describe 'POST /webpush_subscriptions' do
    it 'creates the subscription from a flat JSON body' do
      expect do
        post webpush_subscriptions_path(format: :json), params: subscription_payload.to_json, headers: json_headers
      end.to change(WebpushSubscription, :count).by(1)

      expect(response).to have_http_status(:created)

      subscription = WebpushSubscription.last
      expect(subscription.user).to eq(user)
      expect(subscription.endpoint).to eq('https://push.example.com/abc')
      expect(subscription.p256dh_key).to eq('p256dh')
      expect(subscription.auth_key).to eq('auth')
    end

    it 'does not duplicate an existing subscription' do
      post webpush_subscriptions_path(format: :json), params: subscription_payload.to_json, headers: json_headers

      expect do
        post webpush_subscriptions_path(format: :json), params: subscription_payload.to_json, headers: json_headers
      end.not_to change(WebpushSubscription, :count)
    end
  end
end
