# frozen_string_literal: true

class CreateDiscussions < ActiveRecord::Migration[7.0]
  def change
    create_table :discussions do |t|
      t.references :section, null: false, foreign_key: true
      t.string :name
      t.boolean :private # rubocop:disable Rails/ThreeStateBooleanColumn
      t.boolean :system # rubocop:disable Rails/ThreeStateBooleanColumn

      t.timestamps
    end
  end
end
