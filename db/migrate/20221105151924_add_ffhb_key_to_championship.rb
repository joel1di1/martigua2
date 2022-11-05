# frozen_string_literal: true

class AddFfhbKeyToChampionship < ActiveRecord::Migration[7.0]
  def change
    add_column :championships, :ffhb_key, :string
  end
end
