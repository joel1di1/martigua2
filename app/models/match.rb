class Match < ActiveRecord::Base
  belongs_to :championship
  belongs_to :location
  belongs_to :local_team, class_name: Team, foreign_key: :local_team_id
  belongs_to :visitor_team, class_name: Team, foreign_key: :visitor_team_id

  scope :date_ordered, -> { order('start_datetime ASC') }

  scope :with_start_between, ->(start_period, end_period) { where("start_datetime >= ? AND start_datetime <= ?", start_period, end_period) } 
  
  def date
    if start_datetime
      start_datetime.to_s(:short)
    else
      "(#{prevision_period_start.to_s(:short)} - #{prevision_period_end.to_s(:short)})"
    end
  end

  def users
    @users = User.joins(sections: :teams).where('teams.id IN (?)', [local_team.id, visitor_team.id])
  end

  def self.send_availability_mail_for_next_weekend
    User.all.each do |user|
      next_weekend_matches = user.next_weekend_matches
      UserMailer.delay.send_match_invitation(next_weekend_matches.to_a, user) unless next_weekend_matches.empty?
    end
  end

  def self.of_next_weekend(date=DateTime.now)
    start_period = date.at_beginning_of_week
    end_period = start_period.at_end_of_week
    Match.with_start_between(start_period, end_period)
  end

end
