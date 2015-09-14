class AddDayToMatch < ActiveRecord::Migration
  def change
    add_reference :matches, :day, index: true
  end
end
