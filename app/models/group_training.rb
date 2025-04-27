# frozen_string_literal: true

class GroupTraining < ApplicationRecord
  belongs_to :group
  belongs_to :training
end
