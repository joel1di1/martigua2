# frozen_string_literal: true

class User < ApplicationRecord
  # Training presence: declaring, confirming and querying attendance.
  module Attendance
    extend ActiveSupport::Concern

    included do
      has_many :training_presences, inverse_of: :user, dependent: :destroy
    end

    def present_for!(*trainings)
      set_presence_for!(true, *trainings)
    end

    def not_present_for!(*trainings)
      set_presence_for!(false, *trainings)
    end

    def present_for?(training)
      training_presences.where(training:).first.try(:is_present)
    end

    def set_present_for?(training)
      !training_presences.where(training:).first.is_present.nil?
    end

    def was_present?(training, presences_by_user_and_training = nil)
      training_presence = if presences_by_user_and_training.present?
                            presences_by_user_and_training[[id, training.id]]
                          else
                            training_presences.where(training:).first
                          end
      return false if training_presence.blank?

      training_presence.presence_validated? || (training_presence.is_present? && training_presence.presence_validated.nil?)
    end

    def confirm_presence!(training)
      confirm_presence_for!(training, true)
    end

    def confirm_no_presence!(training)
      confirm_presence_for!(training, false)
    end

    def next_week_trainings(date: DateTime.now)
      start_date = date.next_week
      end_date = start_date + 1.week
      days_to_check = (start_date..end_date).to_a.map(&:to_date)

      days_to_check.reject! { |d| absences.any? { |a| d.between?(a.start_at, a.end_at) } }

      Training.with_start_on(days_to_check)
              .includes(:groups)
              .where(groups: { id: group_ids })
    end

    private

    def set_presence_for!(present, *trainings)
      trainings = trainings.flat_map { |training_or_collection| Array.wrap(training_or_collection) }

      presences = training_presences.index_by(&:training_id)

      trainings.each do |training|
        next if present && training.max_capacity_reached?

        presence = presences[training.id]
        if presence.nil?
          training_presences << TrainingPresence.new(training:, user: self, is_present: present)
        else
          presence.update is_present: present
        end
      end
    end

    def confirm_presence_for!(training, presence)
      training_presence = training_presences.find_or_create_by(training:)
      training_presence.update!(presence_validated: presence)
    end
  end
end
