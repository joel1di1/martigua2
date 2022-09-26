# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'admin@martigua.org'
  layout 'mailer'
end
