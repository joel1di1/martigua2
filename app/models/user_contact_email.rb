# frozen_string_literal: true

# An additional address copied on everything the player receives, typically a parent's.
# The person behind it has no account: they act through the magic links in those mails.
class UserContactEmail < ApplicationRecord
  belongs_to :user, inverse_of: :contact_emails

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, format: { with: Devise.email_regexp }
  validates :email, uniqueness: { scope: :user_id }

  def to_s
    label.blank? ? email : "#{label} - #{email}"
  end
end
