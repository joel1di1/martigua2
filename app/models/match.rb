# frozen_string_literal: true

class Match < ApplicationRecord # rubocop:disable Metrics/ClassLength
  belongs_to :championship
  belongs_to :location, optional: true
  belongs_to :day

  # TODO: match should link to enrolled teams instead of teams
  belongs_to :local_team, class_name: 'Team'
  belongs_to :visitor_team, class_name: 'Team'

  has_many :selections, inverse_of: :match, dependent: :destroy
  has_many :match_availabilities, inverse_of: :match, dependent: :destroy
  has_many :match_invitations, inverse_of: :match, dependent: :destroy
  has_many :player_match_stats, dependent: :destroy

  scope :join_day, -> { joins('LEFT OUTER JOIN days ON days.id = matches.day_id') }
  scope :date_ordered, -> { order(Arel.sql('LEAST(days.period_end_date, start_datetime) ASC')) }

  scope :with_start_between, lambda { |start_period, end_period|
                               where(start_datetime: start_period..end_period)
                             }
  scope :on_days, ->(days) { where('DATE(start_datetime) IN (?)', days) }

  delegate :burned?, to: :championship

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
    section_ids = Team.joins(:team_sections)
                      .where(id: [local_team_id, visitor_team_id])
                      .pluck('team_sections.section_id')
                      .uniq

    User.joins(:participations).where(participations: {
                                        season: Season.current,
                                        role: Participation::PLAYER,
                                        section_id: section_ids
                                      })
  end

  def _availables
    away_user_ids = aways.pluck(:id)
    match_availabilities.includes(:user).where(available: true).where.not(user_id: away_user_ids)
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
    (_not_availables.map(&:user) + aways).uniq
  end

  def aways
    users.joins(:absences)
         .where('absences.start_at <= ? AND absences.end_at >= ?', start_datetime || day.period_start_date, end_datetime || day.period_end_date)
  end

  def nb_aways
    aways.count
  end

  def nb_not_availables
    not_availables.count
  end

  def nb_availability_not_set
    availability_not_set.size
  end

  def availability_not_set
    users.uniq - availables - not_availables
  end

  def self.send_availability_mail_for_next_weekend
    User.where("email not like '%@example.com'").active_this_season.each do |user|
      next_7_days_matches = user.next_7_days_matches
      UserMailer.send_match_invitation(next_7_days_matches.to_a, user) unless next_7_days_matches.empty?
    end
  end

  def teams
    Team.where(id: [local_team_id, visitor_team_id])
  end

  def selections_for(team)
    Selection.includes(:user).where(match: self, team:)
  end

  def meeting_datetime
    super || start_datetime&.send(:-, 1.hour)
  end

  def ffhb_sync!
    Ffhb::MatchSync.new(self).call
  end

  def sync_player_stats!
    return if fdm_code.blank?
    return if local_score.blank?

    stats = FdmParserService.new(fdm_code).parse
    return if stats.blank?

    records = stats.map do |stat|
      {
        match_id: id,
        player_id: stat[:player_id],
        first_name: stat[:first_name],
        last_name: stat[:last_name],
        jersey_number: stat[:jersey_number],
        captain: stat[:captain],
        goals: stat[:goals],
        seven_meters: stat[:seven_meters],
        shots: stat[:shots],
        saves: stat[:saves],
        warnings: stat[:warnings],
        two_minutes: stat[:two_minutes],
        disqualifications: stat[:disqualifications],
        created_at: Time.zone.now,
        updated_at: Time.zone.now
      }
    end

    PlayerMatchStat.upsert_all(records, unique_by: %i[match_id player_id]) # rubocop:disable Rails/SkipsModelValidations

    link_player_match_stats_to_users(records)
  end

  def calculated_start_datetime
    start_datetime || day&.period_start_date
  end

  private

  def link_player_match_stats_to_users(_records)
    linked_ucs = UserChampionshipStat.where(championship: championship).where.not(user_id: nil)
    ucs_by_name = linked_ucs.index_by { |ucs| normalize_name(ucs.last_name, ucs.first_name) }

    PlayerMatchStat.where(match_id: id, user_id: nil).find_each do |pms|
      key = normalize_name(pms.last_name, pms.first_name)
      ucs = ucs_by_name[key]
      pms.update_column(:user_id, ucs.user_id) if ucs # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def normalize_name(last_name, first_name)
    "#{last_name&.strip&.upcase} #{first_name&.strip&.downcase}"
  end
end
