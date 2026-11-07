# frozen_string_literal: true

class GueulesdeboisMailer < ApplicationMailer
  RECIPIENT = 'joel1di1@gmail.com'

  def notify_new_amuse_gueule(new_events)
    @new_events = new_events
    mail to: RECIPIENT, subject: 'Nouvel Amuse-Gueule sur Gueules de Bois !'
  end
end
