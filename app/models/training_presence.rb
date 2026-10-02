# frozen_string_literal: true

class TrainingPresence < ApplicationRecord
  GROUP_MEMBER_SQL = <<~SQL.squish
    EXISTS (
      SELECT 1 FROM group_trainings
      INNER JOIN group_memberships ON group_memberships.group_id = group_trainings.group_id
      WHERE group_trainings.training_id = training_presences.training_id
        AND group_memberships.user_id = training_presences.user_id
    )
  SQL

  belongs_to :user
  belongs_to :training, inverse_of: :training_presences

  scope :members_of_training_groups, -> { where(GROUP_MEMBER_SQL) }
  scope :non_members_of_training_groups, -> { where.not(GROUP_MEMBER_SQL) }

  # Answers of a user who is no longer in any group of the given upcoming trainings.
  def self.purge_future_non_member(user, trainings)
    upcoming = trainings.where(start_datetime: Time.current..).reorder(nil).select(:id)
    non_members_of_training_groups.where(user:, training_id: upcoming).delete_all
  end
end
