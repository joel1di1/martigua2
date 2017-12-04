class AddSharedCalendarUrlToMatches < ActiveRecord::Migration[5.1]
  def change
    add_column :matches, :shared_calendar_url, :string
  end
end
