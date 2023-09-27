# frozen_string_literal: true

class WebpushService
  # payload = { title: 'Hello', body: 'World' }
  def self.send_notification(subscription,
                             icon: 'https://static.wixstatic.com/media/52897d_00efa59c0af84a7eabebd99c94ee77e9.jpg/v1/fill/w_85,h_80,al_c,q_80,usm_0.66_1.00_0.01,enc_auto/52897d_00efa59c0af84a7eabebd99c94ee77e9.jpg',
                             **payload)
    payload[:icon] = icon

    WebPush.payload_send(
      message: payload.to_json,
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh_key,
      auth: subscription.auth_key,
      vapid: {
        subject: 'https://www.martigua.org',
        public_key: ENV.fetch('VAPID_PUBLIC_KEY', nil),
        private_key: ENV.fetch('VAPID_PRIVATE_KEY', nil)
      }
    )
  rescue WebPush::InvalidSubscription, WebPush::ExpiredSubscription
    subscription.destroy
  end

  def self.send_notification_to_all_user_subscriptions(user, title:, body:)
    user.webpush_subscriptions.each do |subscription|
      send_notification(subscription, title:, body:)
    end
  end
end
