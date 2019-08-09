# frozen_string_literal: true

class AddCalendarToChampionship < ActiveRecord::Migration[5.1]
  def change
    add_reference :championships, :calendar, foreign_key: true
  end
end
