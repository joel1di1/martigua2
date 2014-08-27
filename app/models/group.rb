class Group < ActiveRecord::Base
  belongs_to :section

  has_and_belongs_to_many :users, inverse_of: :groups
  has_and_belongs_to_many :trainings, inverse_of: :groups

  validates_presence_of :name

  def add_user!(user)
    users << user unless users.include?(user)
    self
  end

end