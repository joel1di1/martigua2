# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserMailer do
  describe '#send_training_invitation' do
    let(:user) { create(:user) }
    let(:training1) { create(:training) }
    let(:training2) { create(:training) }

    let(:mail) { UserMailer.send_training_invitation(trainings, user) }

    context 'with 1 training' do
      let(:trainings) { training1 }

      it { expect(mail.body).to match(training1.start_datetime.strftime('%A %-d %HH%M')) }
    end
  end
end
