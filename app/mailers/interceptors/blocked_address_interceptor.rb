# frozen_string_literal: true

# frozen string literal: true

module Interceptors
  class BlockedAddressInterceptor
    def self.delivering_email(message)
      blocked_addresses = BlockedAddress.where(email: message.to).pluck(:email)

      message.to = message.to - blocked_addresses
      message.cc = message.cc - blocked_addresses if message.cc.present?

      # don't send emails to blocked addresses
      message.perform_deliveries = false if message.to.empty?
    end
  end
end
