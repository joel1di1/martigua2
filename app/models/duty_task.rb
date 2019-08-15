# frozen_string_literal: true

class DutyTask < ApplicationRecord
  belongs_to :user, inverse_of: :duty_tasks
  validates_presence_of :user, :name
end


# ==> suppression par coachs

# jeunes: 12
# table: 6
# ballons + colle: 4
# chasubles: 3
# eau: 1
