# frozen_string_literal: true

class BlockedAddress < ApplicationRecord
  validates :email, presence: true, uniqueness: true

  def self.blocked?(email)
    exists?(email:)
  end

  def self.block!(email)
    create(email:)
  end

  def self.unblock!(email)
    find_by(email:)&.destroy
  end
end
