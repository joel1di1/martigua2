# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'RGPD anonymization of inactive accounts' do
    let(:old_season) { create(:season, start_date: 5.years.ago.to_date, end_date: 4.years.ago.to_date) }
    let(:section) { create(:section) }
    let(:user) do
      create(:user, created_at: 6.years.ago, current_sign_in_at: 4.years.ago, last_sign_in_at: 5.years.ago,
                    nickname: 'Zizou').tap do |u|
        create(:participation, user: u, section:, season: old_season, role: Participation::PLAYER)
      end
    end

    describe '.inactive_since' do
      let(:cutoff) { 3.years.ago }

      it 'finds an account with no membership, sign-in nor creation since the cutoff' do
        expect(User.inactive_since(cutoff)).to include(user)
      end

      it 'keeps a member of a recent season' do
        create(:participation, user:, section:, role: Participation::PLAYER)

        expect(User.inactive_since(cutoff)).not_to include(user)
      end

      it 'keeps someone who signed in recently, e.g. a parent through a mailed link' do
        user.update!(current_sign_in_at: 1.month.ago)

        expect(User.inactive_since(cutoff)).not_to include(user)
      end

      it 'keeps a recent account and the super admins' do
        recent = create(:user)
        user.update!(super_admin: true)

        expect(User.inactive_since(cutoff)).not_to include(recent, user)
      end
    end

    describe '.anonymize_inactive!' do
      it 'anonymizes inactive accounts once, and leaves the others alone' do
        user
        active = create(:user)
        User.anonymize_inactive!

        expect(user.reload.email).to eq "anonyme-#{user.id}@anonymized.invalid"
        expect(active.reload.email).not_to include('anonymized')
        expect(User.inactive_since(3.years.ago)).to be_empty
      end
    end

    describe '#anonymize!' do
      it 'drops what identifies the person and keeps the sports history' do
        token = user.generate_token_for(:email_authentication)
        create(:absence, user:)
        create(:user_contact_email, user:, email: 'maman@example.com')
        stat = create(:player_match_stat, user:)

        user.anonymize!

        expect(user.reload).to have_attributes(first_name: 'Ancien', last_name: "Membre #{user.id}", nickname: nil,
                                               phone_number: nil)
        expect(user.absences).to be_empty
        expect(user.contact_emails).to be_empty
        expect(user.participations.count).to eq 1
        expect(stat.reload).to have_attributes(user_id: user.id, first_name: nil, last_name: nil)
        expect(User.find_by_token_for(:email_authentication, token)).to be_nil
      end
    end
  end
end
