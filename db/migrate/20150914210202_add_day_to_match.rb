class AddDayToMatch < ActiveRecord::Migration[4.2]
  def change
    add_reference :matches, :day, index: true
  end
end
