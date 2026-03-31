# frozen_string_literal: true

class AddCompetitionKeyToChampionships < ActiveRecord::Migration[8.1]
  def up
    add_column :championships, :competition_key, :string
    add_index :championships, %i[season_id competition_key]

    Championship.find_each do |championship|
      parts = championship.ffhb_key.to_s.split
      next if parts.size < 3

      championship.update_column(:competition_key, parts[2]) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def down
    remove_column :championships, :competition_key
  end
end
