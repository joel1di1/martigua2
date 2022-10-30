# frozen_string_literal: true

class Training < ApplicationRecord
  belongs_to :location, optional: true

  has_and_belongs_to_many :sections, inverse_of: :trainings
  has_and_belongs_to_many :groups, inverse_of: :trainings

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
                               where('start_datetime >= ? AND start_datetime <= ?', start_period, end_period)
                             }

  default_scope { order 'start_datetime, location_id' }

  paginates_per 10

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
                     sections:, groups:, location:)
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
    present_players.left_outer_joins(:duty_tasks)
                   .distinct.select('users.*, max(duty_tasks.realised_at) as last_duty_date, ' \
                                    'COALESCE(sum(duty_tasks.weight), -1) as sum_duty_tasks_weight')
                   .group('users.id').order('sum_duty_tasks_weight, last_duty_date ASC, authentication_token ASC')
                   .limit(limit)
  end

  def name
    "#{start_datetime.strftime('%d %b')} - #{location&.name}"
  end

  def self.send_presence_mail_for_next_week(date: DateTime.now)
    User.active_this_season.each do |user|
      next_week_trainings = user.next_week_trainings(date: date)
      UserMailer.delay.send_training_invitation(next_week_trainings.to_a, user) unless next_week_trainings.empty?
    end
  end

  def self.send_tig_mail_for_next_training(day_range = 1)
    tomorrow = Date.tomorrow
    trainings =
      Training
      .where(cancelled: [false, nil])
      .where('start_datetime between ? and ?', tomorrow.to_datetime, (tomorrow + day_range.days).to_datetime)
      .order(:start_datetime)

    trainings.each_with_index do |training, _index|
      next_duties = training.next_duties(DUTY_PER_TRAINING)
      UserMailer.delay.send_tig_mail_for_training(training, next_duties) if next_duties.present?
    end
  end

  def self.of_next_week(section: nil, date: DateTime.now)
    start_period = date.next_week
    end_period = start_period.end_of_week
    trainings = Training.with_start_between(start_period, end_period)
    trainings = trainings.of_section(section) unless section.nil?
    trainings
  end
end
