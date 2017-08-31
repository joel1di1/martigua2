class Day < ActiveRecord::Base
  belongs_to :calendar
  has_many :matches, inverse_of: :day

  validates_presence_of :name

  before_save :set_default_period_end_date

  # before_create :set_default_name

  protected
    def set_default_period_end_date
      if self.period_start_date_changed? && self.period_start_date && !self.period_end_date_changed?
        self.period_end_date = self.period_start_date + 1
      end
    end
  # def set_default_name
  #   p self
  #   if self.name.blank?
  #     if self.period_start_date && self.period_end_date
  #       self.name = "#{self.period_start_date.to_s(:short)} - #{self.period_end_date.to_s(:short)}"
  #     end
  #   end
  # end
end

