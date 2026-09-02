# frozen_string_literal: true

# Copies a player's relatives on the Devise mails (password reset, invitation), the same way
# UserMailer does for training and match invitations.
class MartiguaDeviseMailer < Devise::Mailer
  def headers_for(action, opts)
    headers = super
    return headers unless resource.respond_to?(:contact_email_addresses)

    cc = resource.contact_email_addresses.presence
    cc ? headers.merge(cc:) : headers
  end
end
