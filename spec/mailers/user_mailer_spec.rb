# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserMailer, :type => :mailer do
  describe '#send_training_invitation' do
    let(:user) { create :user }
    let(:training_1) { create :training }
    let(:training_2) { create :training }

    let(:mail) { UserMailer.send_training_invitation(trainings, user) }

    context 'with 1 training' do
      let(:trainings) { training_1 }

      it { expect(mail.body).to match(training_1.start_datetime.strftime("%A %-d %HH%M")) }
    end
  end
end
