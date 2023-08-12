# frozen_string_literal: true

class UserChannelMessage < ApplicationRecord
  belongs_to :user
  belongs_to :channel
  belongs_to :message
end
