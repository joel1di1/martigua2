# frozen_string_literal: true

class AddClubToDutyTask < ActiveRecord::Migration[7.0]
  def change
    add_reference :duty_tasks, :club, foreign_key: true
  end
end
