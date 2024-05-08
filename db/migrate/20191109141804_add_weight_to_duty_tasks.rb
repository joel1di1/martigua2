# frozen_string_literal: true

class AddWeightToDutyTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :duty_tasks, :weight, :integer, null: false, default: 0 # rubocop:disable Rails/BulkChangeTable
    add_column :duty_tasks, :key, :string
  end
end
