class Match < ActiveRecord::Base
  belongs_to :championship
  belongs_to :location
  belongs_to :day
  belongs_to :local_team, class_name: Team, foreign_key: :local_team_id
  belongs_to :visitor_team, class_name: Team, foreign_key: :visitor_team_id

  has_many :selections, inverse_of: :match
  has_many :match_availabilities, inverse_of: :match

  scope :join_day, -> { joins('LEFT OUTER JOIN days ON days.id = matches.day_id') }
  scope :date_ordered, -> { order('LEAST(days.period_end_date, start_datetime) ASC') }

  scope :with_start_between, ->(start_period, end_period) { where("start_datetime >= ? AND start_datetime <= ?", start_period, end_period) } 
  
  def date
    if start_datetime
      start_datetime.to_s(:short)
    elsif day
      day.name
    elsif prevision_period_start && prevision_period_end
        "(#{prevision_period_start.to_s(:short)} - #{prevision_period_end.to_s(:short)})"
    else
      ""
    end
  end

  def users
    @users = User.joins(sections: :teams).where('teams.id IN (?)', [local_team,visitor_team].compact.map(&:id))
  end

  def _availables
    match_availabilities.includes(:user).where(available: true)
  end

  def availables
    _availables.map(&:user)
  end

  def nb_availables
    _availables.count
  end

  def _not_availables
    match_availabilities.includes(:user).where(available: false)
  end

  def not_availables
    _not_availables.map(&:user)
  end

  def nb_not_availables
    _not_availables.count
  end

  def nb_availability_not_set
    availability_not_set.size
  end

  def availability_not_set
    users.uniq - availables - not_availables
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

  def teams
    [local_team, visitor_team]
  end

  def selections(team)
    Selection.includes(:user).where(match: self, team: team)
  end

end
