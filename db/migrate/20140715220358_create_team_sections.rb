class CreateTeamSections < ActiveRecord::Migration
  def change
    create_table :team_sections do |t|
      t.belongs_to :team, null:false, index: true
      t.belongs_to :section, null:false, index: true

      t.timestamps
    end
  end
end
