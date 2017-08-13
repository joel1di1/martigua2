class CreateDays < ActiveRecord::Migration[4.2]
  def change
    create_table :days do |t|
      t.string :name, null: false
      t.references :season, index: true, null: false
      t.date :period_start_date
      t.date :period_end_date

      t.timestamps
    end
  end
end
