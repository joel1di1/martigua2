# frozen_string_literal: true

class CreateSectionUserInvitations < ActiveRecord::Migration[4.2]
  def change
    create_table :section_user_invitations do |t|
      t.belongs_to :section, index: true, null: false
      t.string :email, null: false
      t.string :first_name
      t.string :last_name
      t.string :nickname
      t.string :phone_number

      t.string :roles

      t.timestamps
    end
  end
end
