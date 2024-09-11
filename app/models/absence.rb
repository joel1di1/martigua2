# frozen_string_literal: true

class Absence < ApplicationRecord
  MOTIVES = %w[Blessure Maladie Perso Travail Autre].freeze

  validates :name, presence: true, inclusion: { in: MOTIVES }

  belongs_to :user
end
