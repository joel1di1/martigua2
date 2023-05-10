# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'admin@martigua.org'
  layout 'mailer'

  def mail(headers = {}, &block)
    return if BlockedAddress.blocked?(headers[:to])

    super
  end
end
