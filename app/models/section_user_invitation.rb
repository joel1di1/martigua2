# frozen_string_literal: true

class SectionUserInvitation < ActiveRecord::Base
  belongs_to :section

  validates_presence_of :section, :email
end
