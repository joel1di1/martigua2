# frozen_string_literal: true

class SectionUserInvitation < ApplicationRecord
  belongs_to :section

  validates_presence_of :section, :email
end
