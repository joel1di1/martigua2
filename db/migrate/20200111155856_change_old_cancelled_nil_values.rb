# frozen_string_literal: true

class ChangeOldCancelledNilValues < ActiveRecord::Migration[6.0]
  def up
    Training.where(cancelled: nil).update_all(cancelled: false)
  end

  def down; end
end
