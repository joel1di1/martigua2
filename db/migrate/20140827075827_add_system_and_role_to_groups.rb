class AddSystemAndRoleToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :system, :boolean, null: false, default: false
    add_column :groups, :role, :string
  end
end
