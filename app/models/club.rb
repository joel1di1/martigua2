class Club < ActiveRecord::Base

  validates_presence_of :name

  has_many :sections, inverse_of: :club, dependent: :destroy

end
