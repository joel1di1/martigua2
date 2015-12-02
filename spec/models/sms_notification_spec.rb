require 'rails_helper'

RSpec.describe SmsNotification, type: :model do
  it { should belong_to :section }
  it { should validate_presence_of :section }

  describe '.create' do
    let(:section) { create :section } 
    let!(:users) do
      (2..10).to_a.sample.times do
        section.add_player!(create(:user, with_section: section))
      end
    end

    it 'should call SendSmsJob' do
      section.players.each{|user| expect(SendSmsJob).to receive(:perform_later).with(kind_of(SmsNotification), user) }
      sms_notification = create :sms_notification, section: section
    end
  end
end