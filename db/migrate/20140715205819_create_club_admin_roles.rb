# frozen_string_literal: true

class CreateClubAdminRoles < ActiveRecord::Migration[4.2]
  def change
    create_table :club_admin_roles do |t|
      t.belongs_to :club, null: false, index: true
      t.belongs_to :user, null: false, index: true
      t.string :name, null: false

      t.timestamps
    end
  end
end
