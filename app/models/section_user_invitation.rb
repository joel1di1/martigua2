# frozen_string_literal: true

class SectionUserInvitation < ApplicationRecord
  belongs_to :section

  validates :email, presence: true
end
