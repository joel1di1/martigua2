# frozen_string_literal: true

class AddSystemAndRoleToGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :system, :boolean, null: false, default: false
    add_column :groups, :role, :string
  end
end
