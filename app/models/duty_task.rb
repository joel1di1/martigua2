# frozen_string_literal: true

class DutyTask < ApplicationRecord
  belongs_to :user, inverse_of: :duty_tasks
  validates_presence_of :user, :name

  def self.next_duties(limit)
    Section.find(1).players.left_outer_joins(:duty_tasks)
      .distinct.select('users.*, max(duty_tasks.created_at) as last_duty_date')
      .group('users.id').order('last_duty_date DESC, authentication_token ASC')
      .limit(limit)
  end
end


# ==> suppression par coachs

# jeunes: 12
# table: 6
# ballons + colle: 4
# chasubles: 3
# eau: 1
