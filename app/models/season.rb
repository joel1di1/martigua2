class Season < ActiveRecord::Base
  validates_presence_of :name, :start_date, :end_date 

end
