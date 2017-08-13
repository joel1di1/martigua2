class CreateChampionships < ActiveRecord::Migration[4.2]
  def change
    create_table :championships do |t|
      t.belongs_to :season, index: true, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
