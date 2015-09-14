class Day < ActiveRecord::Base
  belongs_to :season

  validates_presence_of :season, :name

  # before_create :set_default_name

  # protected 
  # def set_default_name
  #   p self
  #   if self.name.blank?
  #     if self.period_start_date && self.period_end_date
  #       self.name = "#{self.period_start_date.to_s(:short)} - #{self.period_end_date.to_s(:short)}" 
  #     end
  #   end
  # end
end

