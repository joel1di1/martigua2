# frozen_string_literal: true

# Turns a parent account into a contact email of their child's account.
#
# Some parents were given a player account before contact emails existed, just so the club
# could write to them. This moves their address onto the child as a relative address and
# deletes the now useless account, in one transaction.
class UserMergeService
  class Error < StandardError; end

  def self.call(...)
    new(...).call
  end

  def initialize(source:, target:, label: nil)
    @source = source
    @target = target
    @label = label.presence || source.full_name
  end

  def call
    raise Error, 'Le compte à supprimer et le compte cible doivent être différents' if @source == @target

    User.transaction do
      add_contact_email
      @source.destroy!
    end
    @target
  end

  private

  def add_contact_email
    email = @source.email.to_s.strip.downcase
    return if @target.contact_emails.exists?(email:)

    @target.contact_emails.create!(email:, label: @label)
  end
end
