# frozen_string_literal: true

class ClearUsersSignInIps < ActiveRecord::Migration[8.1]
  def up
    safety_assured { execute 'UPDATE users SET current_sign_in_ip = NULL, last_sign_in_ip = NULL' }
  end

  def down; end
end
