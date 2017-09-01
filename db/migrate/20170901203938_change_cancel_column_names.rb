class ChangeCancelColumnNames < ActiveRecord::Migration[5.1]
  def change
    rename_column :trainings, :cancelation_reason, :cancel_reason
    rename_column :trainings, :canceled, :cancelled
  end
end
