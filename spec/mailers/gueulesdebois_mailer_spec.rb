# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GueulesdeboisMailer do
  describe '#notify_new_amuse_gueule' do
    let(:events) { create_list(:gueulesdebois_event, 2) }
    let(:mail) { described_class.notify_new_amuse_gueule(events) }

    it 'envoie à joel1di1@gmail.com' do
      expect(mail.to).to eq(['joel1di1@gmail.com'])
    end

    it 'a le bon sujet' do
      expect(mail.subject).to eq('Nouvel Amuse-Gueule sur Gueules de Bois !')
    end

    it 'contient les titres des événements' do
      body = CGI.unescapeHTML(mail.body.encoded)
      events.each do |event|
        expect(body).to include(event.title)
      end
    end
  end
end
