# frozen_string_literal: true

class CreateGroupMemberships < ActiveRecord::Migration[6.1]
  def change
    create_table :group_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end

    # Add a unique index to prevent duplicate associations
    add_index :group_memberships, %i[user_id group_id], unique: true

    # Copy data from groups_users to group_memberships
    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          INSERT INTO group_memberships (user_id, group_id, created_at, updated_at)
          SELECT user_id, group_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM groups_users
        SQL
      end
    end

    # Don't drop the old table yet - do it in another migration after confirming everything works
    # drop_table :groups_users
  end
end
