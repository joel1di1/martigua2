# frozen_string_literal: true

class AddSuperAdminToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :super_admin, :boolean, default: false, null: false

    # super admin used to be hardcoded as the user with id 1
    execute 'UPDATE users SET super_admin = TRUE WHERE id = 1'
  end

  def down
    remove_column :users, :super_admin
  end
end
