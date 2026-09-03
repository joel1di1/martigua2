# frozen_string_literal: true

require 'rails_helper'

describe UserMergeService do
  let(:section) { create(:section) }
  let(:parent) { create(:user, email: 'Maman@Example.com', with_section: section) }
  let(:child) { create(:user, with_section: section) }

  it 'copies the deleted account address onto the target as a contact email' do
    UserMergeService.call(source: parent, target: child)

    expect(child.reload.contact_email_addresses).to eq ['maman@example.com']
  end

  it 'labels the contact email with the deleted account name' do
    parent_name = parent.full_name
    UserMergeService.call(source: parent, target: child)

    expect(child.reload.contact_emails.first.label).to eq parent_name
  end

  it 'accepts a custom label' do
    UserMergeService.call(source: parent, target: child, label: 'Maman')

    expect(child.reload.contact_emails.first.label).to eq 'Maman'
  end

  it 'deletes the source account' do
    parent
    child

    expect { UserMergeService.call(source: parent, target: child) }.to change(User, :count).by(-1)
    expect(User.exists?(parent.id)).to be false
  end

  it 'deletes what the source account left behind' do
    channel = create(:channel, section:)
    create(:message, user: parent, channel:)
    create(:absence, user: parent)
    create(:participation, user: parent, section:)

    expect { UserMergeService.call(source: parent, target: child) }.to change(Message, :count).by(-1)
    expect(Absence.where(user_id: parent.id)).to be_empty
    expect(Participation.where(user_id: parent.id)).to be_empty
  end

  it 'refuses to merge an account into itself' do
    expect { UserMergeService.call(source: parent, target: parent) }.to raise_error(UserMergeService::Error)
    expect(User.exists?(parent.id)).to be true
  end

  it 'does not duplicate an address the target already has' do
    child.contact_emails.create!(email: parent.email, label: 'Maman')

    expect { UserMergeService.call(source: parent, target: child) }.not_to change(UserContactEmail, :count)
    expect(User.exists?(parent.id)).to be false
  end

  it 'keeps the source account when the contact email is invalid' do
    parent.update_column(:email, 'not-an-email') # rubocop:disable Rails/SkipsModelValidations

    expect { UserMergeService.call(source: parent, target: child) }.to raise_error(ActiveRecord::RecordInvalid)
    expect(User.exists?(parent.id)).to be true
  end
end
