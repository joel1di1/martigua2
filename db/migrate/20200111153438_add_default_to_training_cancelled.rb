# frozen_string_literal: true

class AddDefaultToTrainingCancelled < ActiveRecord::Migration[6.0]
  def up
    change_column_default :trainings, :cancelled, false
  end
end
