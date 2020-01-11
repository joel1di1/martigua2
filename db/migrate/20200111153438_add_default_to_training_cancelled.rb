# frozen_string_literal: true

class AddDefaultToTrainingCancelled < ActiveRecord::Migration[6.0]
  def change
    change_column_default :trainings, :cancelled, false
  end
end
