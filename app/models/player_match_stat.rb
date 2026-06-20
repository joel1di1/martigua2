# frozen_string_literal: true

class PlayerMatchStat < ApplicationRecord
  belongs_to :match
  belongs_to :user, optional: true

  scope :for_season, ->(season) { joins(match: :championship).where(championships: { season: season }) }
  scope :for_championship, ->(championship) { joins(:match).where(matches: { championship_id: championship.id }) }
  scope :for_user, ->(user) { where(user: user) }
  scope :in_date_range, ->(start_date, end_date) { joins(:match).where(matches: { start_datetime: start_date..end_date }) }
end
