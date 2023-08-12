# frozen_string_literal: true

class AddFfhbIdToLocation < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :ffhb_id, :string
  end
end
