class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.belongs_to :section, index: true
      t.string :description
      t.string :color

      t.timestamps
    end
  end
end
