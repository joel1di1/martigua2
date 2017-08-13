class CreateParticipations < ActiveRecord::Migration[4.2]
  def change
    create_table :participations do |t|
      t.belongs_to :user, index: true, null: false
      t.belongs_to :section, index: true, null: false
      t.belongs_to :season, index: true, null: false
      t.string :role, null: false

      t.timestamps
    end
  end
end
