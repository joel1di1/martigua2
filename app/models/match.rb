class Match < ActiveRecord::Base
  belongs_to :championship
  belongs_to :location
  belongs_to :local_team, class_name: Team, foreign_key: :local_team_id
  belongs_to :visitor_team, class_name: Team, foreign_key: :visitor_team_id

  scope :date_ordered, -> { order('start_datetime ASC') }

  def date
    if start_datetime
      start_datetime.to_s(:short)
    else
      "(#{prevision_period_start.to_s(:short)} - #{prevision_period_end.to_s(:short)})"
    end
  end

end
