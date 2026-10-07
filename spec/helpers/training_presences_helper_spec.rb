# frozen_string_literal: true

require 'rails_helper'

describe TrainingPresencesHelper do
  describe '#declared_presence_label and #declared_presence_background' do
    it 'describes a player who said they would come' do
      presence = build(:training_presence, is_present: true, presence_validated: false)
      expect(helper.declared_presence_label(presence)).to eq('A dit présent')
      expect(helper.declared_presence_background(presence)).to eq('bg-green-200')
    end

    it 'describes a player who said they would not come' do
      presence = build(:training_presence, is_present: false, presence_validated: true)
      expect(helper.declared_presence_label(presence)).to eq('A dit absent')
      expect(helper.declared_presence_background(presence)).to eq('bg-red-200')
    end

    it 'describes a player who did not answer, whether or not a coach validated them' do
      [nil, build(:training_presence, is_present: nil, presence_validated: true)].each do |presence|
        expect(helper.declared_presence_label(presence)).to eq('Pas de réponse')
        expect(helper.declared_presence_background(presence)).to eq('bg-yellow-200')
      end
    end
  end
end
