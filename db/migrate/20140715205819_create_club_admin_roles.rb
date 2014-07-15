class CreateClubAdminRoles < ActiveRecord::Migration
  def change
    create_table :club_admin_roles do |t|
      t.belongs_to :club, null:false, index: true
      t.belongs_to :user, null:false, index: true
      t.string :name, null: false

      t.timestamps
    end
  end
end
