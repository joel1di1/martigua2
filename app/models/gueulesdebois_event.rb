# frozen_string_literal: true

class GueulesdeboisEvent < ApplicationRecord
  validates :title, presence: true
  validates :event_url, presence: true, uniqueness: true
end
