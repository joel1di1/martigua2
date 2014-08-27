class CreateGroupsUsers < ActiveRecord::Migration
  def change
    create_table :groups_users, id: false do |t|
      t.belongs_to :user, index: true, null: false
      t.belongs_to :group, index: true, null: false
    end
  end
end
