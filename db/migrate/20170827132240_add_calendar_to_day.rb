# frozen_string_literal: true

class AddCalendarToDay < ActiveRecord::Migration[5.1]
  def change
    add_reference :days, :calendar, foreign_key: true
  end
end
