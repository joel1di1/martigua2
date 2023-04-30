class Channel < ApplicationRecord
  belongs_to :section
  belongs_to :owner, optional: true, class_name: 'User'
end
