# frozen_string_literal: true

class DutyTask < ApplicationRecord
  belongs_to :user, inverse_of: :duty_tasks
  validates_presence_of :user, :name
end
