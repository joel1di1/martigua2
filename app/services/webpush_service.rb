# frozen_string_literal: true

class WebpushService
  def self.send_notification(subscription, **payload)
    WebPush.payload_send(
      message: payload.to_json,
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh_key,
      auth: subscription.auth_key,
      vapid: {
        subject: 'https://www.martigua.org',
        public_key: ENV['VAPID_PUBLIC_KEY'],
        private_key: ENV['VAPID_PRIVATE_KEY']
      }
    )
  rescue WebPush::InvalidSubscription, WebPush::ExpiredSubscription => e
    subscription.destroy
  end
end

