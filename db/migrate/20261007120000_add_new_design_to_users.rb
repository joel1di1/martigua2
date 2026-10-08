# frozen_string_literal: true

class AddNewDesignToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :new_design, :boolean, default: false, null: false
  end
end
