# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController, type: :controller do
  let(:section) { create :section }
  let(:player) { create :user, with_section: section }
  let(:users) { [player] }

  describe '#prepare_training_presences' do
    subject(:last_trainings) { controller.send(:prepare_training_presences, section, users).first }

    let!(:training) { create :training, sections: [section], start_datetime: 1.month.ago }
    let!(:cancelled_training) { create :training, sections: [section], start_datetime: 1.month.ago, cancelled: true }

    it 'filters cancelled trainings' do
      expect(last_trainings).to eq([training])
    end
  end
end
