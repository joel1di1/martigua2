# frozen_string_literal: true

class Burn < ApplicationRecord
  belongs_to :user
  belongs_to :championship
end
