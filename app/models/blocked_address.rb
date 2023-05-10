# frozen_string_literal: true

class BlockedAddress < ApplicationRecord
  validates :email, presence: true, uniqueness: true

  def self.blocked?(email)
    exists?(email: email)
  end

  def self.block!(email)
    create(email: email)
  end

  def self.unblock!(email)
    find_by(email: email)&.destroy
  end
end
