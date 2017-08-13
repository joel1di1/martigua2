class CreateSections < ActiveRecord::Migration[4.2]
  def change
    create_table :sections do |t|
      t.belongs_to :club, null:false, index: true
      t.string :name, ull: false

      t.timestamps
    end
  end
end
