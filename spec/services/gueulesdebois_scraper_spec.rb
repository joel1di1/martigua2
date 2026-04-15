# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GueulesdeboisScraper do
  describe '.call' do
    let(:html) do
      <<~HTML
        <html><body>
          <a href="/event/atelier-bois/register">
            <h5>Atelier technique : Défonceuse</h5>
          </a>
          <a href="/event/amuse-gueule-3/register">
            <h5>AMUSE-GUEULE #3 : accueil et présentation de l'atelier partagé</h5>
          </a>
          <a href="/event/amuse-gueule-4/register">
            <h5>AMUSE-GUEULE #4 : accueil et présentation de l'atelier partagé</h5>
          </a>
        </body></html>
      HTML
    end

    before do
      allow_any_instance_of(described_class).to receive(:fetch_page).and_return(html)
    end

    it 'retourne uniquement les événements amuse-gueule' do
      result = described_class.call

      expect(result.size).to eq(2)
      expect(result.map { |e| e[:title] }).to all(match(/amuse-gueule/i))
    end

    it 'retourne le titre et l\'url de chaque événement' do
      result = described_class.call

      expect(result.first).to include(
        title: "AMUSE-GUEULE #3 : accueil et présentation de l'atelier partagé",
        event_url: '/event/amuse-gueule-3/register'
      )
    end

    it 'ignore les événements sans titre h5' do
      html_without_h5 = '<html><body><a href="/event/test/register"><span>pas de h5</span></a></body></html>'
      allow_any_instance_of(described_class).to receive(:fetch_page).and_return(html_without_h5)

      expect(described_class.call).to be_empty
    end
  end
end
