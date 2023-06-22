# frozen_string_literal: true

class Channel < ApplicationRecord
  belongs_to :section
  has_many :messages, dependent: :destroy
  has_many :user_channel_messages, inverse_of: :channel, dependent: :destroy
end
