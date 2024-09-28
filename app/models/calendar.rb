# frozen_string_literal: true

class Calendar < ApplicationRecord
  belongs_to :season
  has_many :days, inverse_of: :calendar, dependent: :destroy

  validates :name, presence: true

  def find_or_create_day_for(datetime)
    existing_day = days.order(:id).find do |day|
      day.period_start_date <= datetime && day.period_end_date >= datetime
    end

    return existing_day if existing_day

    period_start_date = datetime.beginning_of_week.to_date
    period_end_date = period_start_date + 1.week
    days.create!(name: "Week #{period_start_date} #{period_end_date - 1.day}", period_start_date:, period_end_date:)
  end
end
