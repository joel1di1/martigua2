# frozen_string_literal: true

class Channel < ApplicationRecord
  belongs_to :section
  has_many :messages, dependent: :destroy
end
