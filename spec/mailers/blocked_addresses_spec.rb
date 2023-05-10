# frozen_string_literal: true

require 'rails_helper'

class SimpleMailer < ApplicationMailer
  def send_email(email)
    mail(to: email, subject: 'test', body: 'test')
  end
end

RSpec.describe BlockedAddress do
  let(:email) { Faker::Internet.email }

  context 'when email is blocked' do
    before { create(:blocked_address, email: email) }

    it { expect(described_class.blocked?(email)).to be_truthy }
    it { expect { SimpleMailer.send_email(email).deliver_now }.not_to change(ActionMailer::Base.deliveries, :count) }
  end

  context 'when email is not blocked' do
    it { expect(described_class.blocked?(email)).to be_falsey }
    it { expect { SimpleMailer.send_email(email).deliver_now }.to change(ActionMailer::Base.deliveries, :count).by(1) }
  end
end
