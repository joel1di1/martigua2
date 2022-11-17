# frozen_string_literal: true

class AssignOldDutyTaskToMartigua < ActiveRecord::Migration[7.0]
  def change
    change_column_null(:duty_tasks, :club_id, false, 1)
  end
end
