# frozen_string_literal: true

class SectionTraining < ApplicationRecord
  belongs_to :section
  belongs_to :training
end
