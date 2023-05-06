# frozen_string_literal: true

# frozen string literal: true

module Interceptors
  class BlockedAddressInterceptor
    def self.delivering_email(message)
      blocked_addresses = %w[
        jeanbaptisteeve577@gmail.com
      ]
      message.to = message.to - blocked_addresses

      # don't send emails to blocked addresses
      message.perform_deliveries = false if message.to.empty?
    end
  end
end
