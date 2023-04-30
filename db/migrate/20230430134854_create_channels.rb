class CreateChannels < ActiveRecord::Migration[7.0]
  def change
    create_table :channels do |t|
      t.string :name
      t.references :section, foreign_key: true
      t.boolean :private
      t.bigint :owner_id, foreign_key: true

      t.timestamps
    end
  end
end
