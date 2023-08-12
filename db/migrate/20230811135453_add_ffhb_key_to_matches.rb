# frozen_string_literal: true

class AddFfhbKeyToMatches < ActiveRecord::Migration[7.0]
  def change
    add_column :matches, :ffhb_key, :string
  end
end
