class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.belongs_to :club, null: false, index: true
      t.string :name

      t.timestamps
    end
  end
end
