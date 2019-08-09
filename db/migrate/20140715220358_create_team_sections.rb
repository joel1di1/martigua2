# frozen_string_literal: true

class CreateTeamSections < ActiveRecord::Migration[4.2]
  def change
    create_table :team_sections do |t|
      t.belongs_to :team, null: false, index: true
      t.belongs_to :section, null: false, index: true

      t.timestamps
    end
  end
end
