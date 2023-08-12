# frozen_string_literal: true

class Day < ApplicationRecord
  belongs_to :calendar
  has_many :matches, inverse_of: :day, dependent: :destroy

  validates :name, presence: true

  before_save :set_default_period_end_date

  protected

  def set_default_period_end_date
    return unless period_start_date_changed? && period_start_date && !period_end_date_changed?

    self.period_end_date = period_start_date + 1
  end
end
