# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserMailer do
  let(:user) { create(:user) }

  describe '#send_training_invitation' do
    let(:training1) { create(:training) }
    let(:training2) { create(:training) }

    let(:mail) { UserMailer.send_training_invitation(trainings, user) }

    context 'with 1 training' do
      let(:trainings) { training1 }

      it { expect(mail.body).to match(training1.start_datetime.strftime('%A %-d %HH%M')) }
    end

    context 'without contact email' do
      let(:trainings) { training1 }

      it 'is sent to the user only' do
        expect(mail.to).to eq [user.email]
        expect(mail.cc).to be_nil
      end
    end

    context 'with contact emails' do
      let(:trainings) { training1 }

      before do
        create(:user_contact_email, user:, email: 'maman@example.com', label: 'Maman')
        create(:user_contact_email, user:, email: 'papa@example.com', label: 'Papa')
      end

      it 'copies the relatives' do
        expect(mail.to).to eq [user.email]
        expect(mail.cc).to contain_exactly('maman@example.com', 'papa@example.com')
      end
    end

    context 'with the one-click links' do
      let(:trainings) { training1 }

      it 'carries the sign-in token on both the positive and the negative link' do
        links = mail.body.to_s.scan(/href="([^"]*training_presences[^"]*)"/).flatten

        expect(links.size).to eq 2
        expect(links).to all(include('user_token='))
      end
    end
  end

  describe '#send_match_invitation' do
    let(:match) { create(:match) }
    let(:mail) { UserMailer.send_match_invitation(match, user) }

    it 'is sent to the user only when there is no relative' do
      expect(mail.to).to eq [user.email]
      expect(mail.cc).to be_nil
    end

    it 'copies the relatives' do
      create(:user_contact_email, user:, email: 'maman@example.com')

      expect(mail.to).to eq [user.email]
      expect(mail.cc).to eq ['maman@example.com']
    end
  end

  describe 'blocked addresses' do
    let(:training) { create(:training) }

    it 'drops a blocked player from a real delivery' do
      BlockedAddress.block!(user.email)

      expect { UserMailer.send_training_invitation(training, user).deliver_now }
        .not_to change(ActionMailer::Base.deliveries, :count)
    end

    it 'still delivers to the relatives when only the player is blocked' do
      create(:user_contact_email, user:, email: 'maman@example.com')
      BlockedAddress.block!(user.email)

      expect { UserMailer.send_training_invitation(training, user).deliver_now }
        .to change(ActionMailer::Base.deliveries, :count).by(1)

      delivered = ActionMailer::Base.deliveries.last
      expect(delivered.to).to be_blank
      expect(delivered.cc).to eq ['maman@example.com']
    end

    it 'drops a blocked relative but keeps the player' do
      create(:user_contact_email, user:, email: 'maman@example.com')
      BlockedAddress.block!('maman@example.com')

      UserMailer.send_training_invitation(training, user).deliver_now

      delivered = ActionMailer::Base.deliveries.last
      expect(delivered.to).to eq [user.email]
      expect(delivered.cc).to be_blank
    end
  end

  describe '#send_section_addition_to_existing_user' do
    let(:section) { create(:section) }
    let(:inviter) { create(:user) }
    let(:mail) { UserMailer.send_section_addition_to_existing_user(user, inviter, section) }

    it 'copies the relatives' do
      create(:user_contact_email, user:, email: 'maman@example.com')

      expect(mail.to).to eq [user.email]
      expect(mail.cc).to eq ['maman@example.com']
    end
  end
end
