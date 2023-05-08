# frozen_string_literal: true

class Message < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :channel
  belongs_to :parent_message, class_name: 'Message', optional: true
  has_many :child_messages, class_name: 'Message', foreign_key: :parent_message_id, dependent: :destroy, inverse_of: :parent_message
  # has_many :reactions, dependent: :destroy

  # Validations
  validates :content, presence: true

  after_create_commit -> { broadcast_append_to channel }

  has_rich_text :content
end
