class Training < ActiveRecord::Base
  belongs_to :location
  has_and_belongs_to_many :sections, inverse_of: :trainings

  validates_presence_of :start_datetime

  scope :of_section, ->(section) { joins(:sections).where("sections.id = ?", section.id) }
end
