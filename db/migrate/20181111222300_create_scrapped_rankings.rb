class CreateScrappedRankings < ActiveRecord::Migration[5.1]
  def change
    create_table :scrapped_rankings do |t|
      t.text :scrapped_content
      t.string :championship_number

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
