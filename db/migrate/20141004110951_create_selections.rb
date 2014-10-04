class CreateSelections < ActiveRecord::Migration
  def change
    create_table :selections do |t|
      t.belongs_to :user, index: true, null: false
      t.belongs_to :match, index: true, null: false
      t.belongs_to :team, index: true, null: false

      t.timestamps
    end
  end
end
