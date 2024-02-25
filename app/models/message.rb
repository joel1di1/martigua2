# frozen_string_literal: true

class Message < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :channel
  belongs_to :parent_message, class_name: 'Message', optional: true
  has_many :child_messages, class_name: 'Message', foreign_key: :parent_message_id, dependent: :destroy,
                            inverse_of: :parent_message
  has_many :user_channel_messages, inverse_of: :message, dependent: :destroy
  # has_many :reactions, dependent: :destroy

  # Validations
  validates :content, presence: true

  after_create_commit -> { broadcast_append_to channel }
  after_create_commit :async_notify_users

  has_rich_text :content

  def notify_users
    title = "New message in #{channel.section.name}"
    body = "#{user.short_name}: #{content.to_plain_text.truncate(50)}"

    channel.section.users.each do |user|
      next if user == self.user

      WebpushService.send_notification_to_all_user_subscriptions(user, title:, body:)
    end
  end
end
