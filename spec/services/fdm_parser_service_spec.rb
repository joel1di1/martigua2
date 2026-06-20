# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FdmParserService do
  describe '.pdf_url_for' do
    it 'builds the correct URL from fdm_code' do
      url = FdmParserService.pdf_url_for('VAGNXUG')
      expect(url).to eq('https://media-ffhb-fdm.ffhandball.fr/fdm/V/A/G/N/VAGNXUG.pdf')
    end
  end

  describe '#parse' do
    context 'with a valid PDF fixture' do
      let(:service) { FdmParserService.new('VAGNXUG') }
      let(:pdf_content) { Rails.root.join('spec/fixtures/ffhb/fdm_sample.pdf').binread }

      before do
        allow(service).to receive(:download_pdf).and_return(pdf_content)
      end

      it 'returns player stats for both teams' do
        result = service.parse
        expect(result.length).to eq(20)
      end

      it 'parses player names correctly' do
        result = service.parse
        stevens = result.find { |p| p[:last_name] == 'STEVENS' }
        expect(stevens[:first_name]).to eq('theo')
      end

      it 'parses multi-word last names' do
        result = service.parse
        le_provost = result.find { |p| p[:last_name] == 'LE PROVOST' }
        expect(le_provost).to be_present
        expect(le_provost[:first_name]).to eq('eliott')
      end

      it 'parses goals correctly' do
        result = service.parse
        stevens = result.find { |p| p[:last_name] == 'STEVENS' }
        expect(stevens[:goals]).to eq(6)
      end

      it 'parses 7m goals correctly' do
        result = service.parse
        stevens = result.find { |p| p[:last_name] == 'STEVENS' }
        expect(stevens[:seven_meters]).to eq(2)
      end

      it 'parses shots correctly' do
        result = service.parse
        stevens = result.find { |p| p[:last_name] == 'STEVENS' }
        expect(stevens[:shots]).to eq(10)
      end

      it 'parses saves correctly' do
        result = service.parse
        dias = result.find { |p| p[:last_name] == 'DIAS' }
        expect(dias[:saves]).to eq(18)
      end

      it 'detects captain' do
        result = service.parse
        stevens = result.find { |p| p[:last_name] == 'STEVENS' }
        expect(stevens[:captain]).to be(true)

        berthier = result.find { |p| p[:last_name] == 'BERTHIER' }
        expect(berthier[:captain]).to be(false)
      end

      it 'parses jersey numbers' do
        result = service.parse
        stevens = result.find { |p| p[:last_name] == 'STEVENS' }
        expect(stevens[:jersey_number]).to eq(10)
      end

      it 'parses warnings' do
        result = service.parse
        naud = result.find { |p| p[:last_name] == 'NAUD' }
        expect(naud[:warnings]).to eq(1)
      end

      it 'parses 2-minute suspensions' do
        result = service.parse
        naud = result.find { |p| p[:last_name] == 'NAUD' }
        expect(naud[:two_minutes]).to eq(1)
      end

      it 'parses licence as player_id' do
        result = service.parse
        stevens = result.find { |p| p[:last_name] == 'STEVENS' }
        expect(stevens[:player_id]).to eq('6244091101165')
      end
    end

    context 'when PDF download fails' do
      let(:service) { FdmParserService.new('INVALID') }

      before do
        allow(service).to receive(:download_pdf).and_return(nil)
      end

      it 'returns an empty array' do
        expect(service.parse).to eq([])
      end
    end
  end
end
