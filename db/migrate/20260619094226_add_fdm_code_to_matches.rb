# frozen_string_literal: true

class AddFdmCodeToMatches < ActiveRecord::Migration[8.1]
  def change
    add_column :matches, :fdm_code, :string
  end
end
