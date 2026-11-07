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

    let(:http_response) { instance_double(Net::HTTPOK, is_a?: true, body: html) }

    before do
      allow(http_response).to receive(:is_a?).with(Net::HTTPRedirection).and_return(false)
      allow(http_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
      allow(Net::HTTP).to receive(:get_response).and_return(http_response)
    end

    it 'retourne uniquement les événements amuse-gueule' do
      result = GueulesdeboisScraper.call

      expect(result.size).to eq(2)
      expect(result.pluck(:title)).to all(match(/amuse-gueule/i))
    end

    it "retourne le titre et l'url de chaque événement" do
      result = GueulesdeboisScraper.call

      expect(result.first).to include(
        title: "AMUSE-GUEULE #3 : accueil et présentation de l'atelier partagé",
        event_url: '/event/amuse-gueule-3/register'
      )
    end

    it 'ignore les événements sans titre h5' do
      html_without_h5 = '<html><body><a href="/event/test/register"><span>pas de h5</span></a></body></html>'
      allow(http_response).to receive(:body).and_return(html_without_h5)

      expect(GueulesdeboisScraper.call).to be_empty
    end
  end
end
