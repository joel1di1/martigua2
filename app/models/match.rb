# frozen_string_literal: true

class Match < ApplicationRecord
  belongs_to :championship
  belongs_to :location, optional: true
  belongs_to :day

  # TODO: match should link to enrolled teams instead of teams
  belongs_to :local_team, class_name: 'Team'
  belongs_to :visitor_team, class_name: 'Team'

  has_many :selections, inverse_of: :match, dependent: :destroy
  has_many :match_availabilities, inverse_of: :match, dependent: :destroy
  has_many :match_invitations, inverse_of: :match, dependent: :destroy

  scope :join_day, -> { joins('LEFT OUTER JOIN days ON days.id = matches.day_id') }
  scope :date_ordered, -> { order(Arel.sql('LEAST(days.period_end_date, start_datetime) ASC')) }

  scope :with_start_between, lambda { |start_period, end_period|
                               where('start_datetime >= ? AND start_datetime <= ?', start_period, end_period)
                             }

  delegate :burned?, to: :championship

  after_save :update_shared_calendar

  def date
    if start_datetime
      start_datetime.to_fs(:short)
    elsif day
      day.name
    elsif prevision_period_start && prevision_period_end
      "(#{prevision_period_start.to_fs(:short)} - #{prevision_period_end.to_fs(:short)})"
    else
      ''
    end
  end

  def users
    User.joins(:participations).where(participations: {
                                        season: Season.current,
                                        role: Participation::PLAYER,
                                        section: teams.includes(:sections).map(&:sections).flatten
                                      })
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
    User.where("email not like '%@example.com'").active_this_season.each do |user|
      next_weekend_matches = user.next_weekend_matches
      UserMailer.send_match_invitation(next_weekend_matches.to_a, user) unless next_weekend_matches.empty?
    end
  end

  def self.of_next_weekend(date: DateTime.now)
    start_period = date.at_beginning_of_week
    end_period = start_period.at_end_of_week
    Match.with_start_between(start_period, end_period)
  end

  def teams
    Team.where(id: [local_team_id, visitor_team_id])
  end

  def selections(team)
    Selection.includes(:user).where(match: self, team:)
  end

  def update_shared_calendar
    nil if Rails.env.test? || start_datetime.blank?
    # event = CalendarService.instance.create_or_update_event(
    #   shared_calendar_id,
    #   "#{local_team.try(:name)} - #{visitor_team.try(:name)}",
    #   nil,
    #   start_datetime, start_datetime + 2.hours,
    #   "#{location.try(:name)}, #{location.try(:address)}"
    # )

    # update! shared_calendar_id: event.id, shared_calendar_url: event.html_link
  end

  def meeting_datetime
    super || start_datetime&.send(:-, 1.hour)
  end

  def ffhb_sync!
    if ffhb_key.blank?
      logger.warn "No ffhb_key for match #{id}"
      return
    end

    match_details = FfhbService.instance.fetch_match_details(*ffhb_key.split)
    if match_details['rencontre']['date'].present?
      self.start_datetime = Time.zone.parse(match_details['rencontre']['date'])
      self.day = championship.find_or_create_day_for(self.start_datetime)
    end

    self.local_score = match_details['rencontre']['equipe1Score']&.to_i
    self.visitor_score = match_details['rencontre']['equipe2Score']&.to_i

    ffhb_id = match_details['rencontre']['equipementId']
    if ffhb_id.present?
      location = Location.find_by(ffhb_id:)
      if location.blank?
        rencontre_details = FfhbService.instance.fetch_rencontre_salle(*ffhb_key.split)
        name = rencontre_details['equipement']['libelle']
        address = <<~TEXT.chomp
          #{rencontre_details['equipement']['libelle']}
          #{rencontre_details['equipement']['rue']}
          #{rencontre_details['equipement']['codePostal']} #{rencontre_details['equipement']['ville']}
        TEXT

        location = Location.create!(name:, address:, ffhb_id:)
      end
      self.location = location
    end

    save!
  end
end
