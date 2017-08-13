class CreateMatches < ActiveRecord::Migration[4.2]
  def change
    create_table :matches do |t|
      t.belongs_to :championship, index: true
      t.integer :local_team_id
      t.integer :visitor_team_id
      t.datetime :start_datetime
      t.datetime :end_datetime
      t.date :prevision_period_start
      t.date :prevision_period_end
      t.integer :local_score
      t.integer :visitor_score
      t.belongs_to :location, index: true
      t.datetime :meeting_datetime
      t.string :meeting_location

      t.timestamps
    end
  end
end
