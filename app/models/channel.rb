class Channel < ApplicationRecord
  belongs_to :section
  belongs_to :owner, optional: true, class_name: 'User'

  validates :name, presence: true
end
