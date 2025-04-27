# frozen_string_literal: true

class Training < ApplicationRecord
  belongs_to :location, optional: true

  has_and_belongs_to_many :sections, inverse_of: :trainings
  has_many :group_trainings, dependent: :destroy
  has_many :groups, through: :group_trainings

  has_many :invitations, class_name: 'TrainingInvitation', dependent: :destroy
  has_many :training_presences, inverse_of: :training, dependent: :destroy
  has_many :present_players, lambda {
                               where(training_presences: { is_present: true })
                             }, through: :training_presences, source: :user
  has_many :users, through: :groups

  validates :start_datetime, presence: true

  scope :of_section, ->(section) { joins(:sections).where(sections: { id: section.id }) }
  scope :not_cancelled, -> { where.not('cancelled') }
  scope :with_start_between, lambda { |start_period, end_period|
                               where(start_datetime: start_period..end_period)
                             }
  scope :with_start_on, ->(days) { where('DATE(start_datetime) in (?)', days) }

  default_scope { order 'start_datetime, location_id' }

  paginates_per 10

  alias_attribute :calculated_start_datetime, :start_datetime

  DUTY_PER_TRAINING = 4

  def send_invitations!
    invitations << TrainingInvitation.new
  end

  def presents
    training_presences.includes(:user).where(is_present: true).map(&:user)
  end

  def nb_presents
    presents.count
  end

  def not_presents
    training_presences.includes(:user).where(is_present: false).map(&:user)
  end

  def nb_not_presents
    not_presents.count
  end

  def nb_presence_not_set
    presence_not_set.size
  end

  def presence_not_set
    users - presents - not_presents
  end

  def group_names
    groups.order('name').map(&:name).join(', ')
  end

  def users
    User.joins(:groups).where(groups: { id: group_ids })
  end

  def repeat_next_week!
    Training.create!(start_datetime: start_datetime + 1.week,
                     end_datetime: end_datetime + 1.week,
                     sections:, groups:, location:, max_capacity:)
  end

  def repeat_until!(end_date)
    training = self
    end_date -= 1.week
    training = training.repeat_next_week! while training.start_datetime < end_date
  end

  def cancel!(reason: 'Raison inconnue')
    self.cancelled = true
    self.cancel_reason = reason
    save!
  end

  def uncancel!
    self.cancelled = false
    self.cancel_reason = nil
    save!
  end

  def next_duties(limit)
    current_season_start = Season.current.start_date
    current_season_end = Season.current.end_date

    present_players
      .where("email NOT LIKE '%@example.com'")
      .joins(<<-SQL.squish)
        LEFT OUTER JOIN duty_tasks
        ON duty_tasks.user_id = users.id
        AND duty_tasks.realised_at BETWEEN '#{current_season_start}' AND '#{current_season_end}'
        AND duty_tasks.club_id IN (#{sections.map(&:club_id).join(',')})
      SQL
      .distinct
      .select(<<-SQL.squish)
        users.*,
        MAX(duty_tasks.realised_at) AS last_duty_date,
        COALESCE(SUM(duty_tasks.weight), -1) AS sum_duty_tasks_weight
      SQL
      .group('users.id')
      .order('sum_duty_tasks_weight, last_duty_date ASC, authentication_token ASC')
      .limit(limit)
  end

  def name
    "#{start_datetime.strftime('%d %b')} - #{location&.name}"
  end

  def self.send_presence_mail_for_next_week(date = DateTime.now)
    User.where("email not like '%@example.com'").active_this_season.each do |user|
      next_week_trainings = user.next_week_trainings(date:)
      unless next_week_trainings.empty?
        UserMailer.send_training_invitation(next_week_trainings.to_a,
                                            user).deliver_later
      end
    end
  end

  def self.send_tig_mail_for_next_training(day_range = 2)
    tomorrow = Date.tomorrow
    trainings =
      Training
      .where(cancelled: [false, nil])
      .where('start_datetime between ? and ?', tomorrow.to_datetime, (tomorrow + day_range.days).to_datetime)
      .order(:start_datetime)

    trainings.each do |training|
      next_duties = training.next_duties(DUTY_PER_TRAINING)
      next if next_duties.blank?
      next if training.sections.map(&:id).uniq == [1]

      # if training is in section 1, than add pechou as last next duty
      cc = training.sections.map(&:id).include?(1) ? User.find(49) : nil

      UserMailer.send_tig_mail_for_training(training, next_duties.to_a, cc).deliver_later
    end
  end

  def max_capacity_reached?
    return false if max_capacity.nil?

    present_players.count >= max_capacity
  end
end
