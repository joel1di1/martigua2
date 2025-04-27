# frozen_string_literal: true

# frozen string literal: true

module Interceptors
  class BlockedAddressInterceptor
    # blocked addresses can be specific emails like "foo@bar" or wildcards like "*@bar.com"
    def self.delivering_email(message)
      remove_specific_blocked_addresses!(message)
      remove_wildcard_blocked_addresses!(message)

      message.perform_deliveries = false if message.to.empty?
    end

    def self.remove_specific_blocked_addresses!(message)
      blocked_addresses = BlockedAddress.where(email: message.to).pluck(:email)

      message.to = message.to - blocked_addresses
      message.cc = message.cc - blocked_addresses if message.cc.present?
    end

    def self.remove_wildcard_blocked_addresses!(message)
      # retrieve all wildcard blocked addresses
      wildcard_blocked_addresses = BlockedAddress.where('email LIKE ?', '*%').pluck(:email)

      # retrieve all wildcard blocked domains, removing the *
      wildcard_blocked_domains = wildcard_blocked_addresses.pluck(1..)

      # remove all blocked addresses matching the wildcard blocked domains
      message.to = message.to.select do |address|
        wildcard_blocked_domains.none? do |domain|
          address.ends_with?(domain)
        end
      end
      return if message.cc.blank?

      message.cc = message.cc.select do |address|
        wildcard_blocked_domains.none? do |domain|
          address.ends_with?(domain)
        end
      end
    end
  end
end
