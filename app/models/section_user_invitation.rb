# frozen_string_literal: true

class SectionUserInvitation < ApplicationRecord
  belongs_to :section

  validates :email, :section, presence: true
end
