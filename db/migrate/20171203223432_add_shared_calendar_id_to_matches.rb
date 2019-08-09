# frozen_string_literal: true

class AddSharedCalendarIdToMatches < ActiveRecord::Migration[5.1]
  def change
    add_column :matches, :shared_calendar_id, :string
  end
end
