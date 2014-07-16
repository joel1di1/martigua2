describe User do

  it { should validate_presence_of :email }
  it { should have_db_column :first_name }
  it { should have_db_column :last_name }
  it { should have_db_column :nickname }
  it { should have_db_column :phone_number }
  it { should have_many :club_admin_roles }
  it { should have_many :participations }
  it { should have_many :sections }

  describe 'authentication token should be generated' do
    subject { create :user, authentication_token: nil }

    its(:authentication_token) { should_not be_nil }
    its(:id) { should_not be_nil }
  end

  describe '#has_only_one_section?' do
    subject { user.has_only_one_section? }

    context 'user with no section' do
      let(:user) { create :user }
      it { should eq false }
    end
    context 'user with two sections' do
      let(:user) { create :user }
      let!(:participation_1) { create :participation, user: user }
      let!(:participation_2) { create :participation, user: user }
      it { should eq false }
    end
    context 'user with one section' do
      let(:user) { create :user }
      let!(:participation_1) { create :participation, user: user }
      it { should eq true }
    end
  end

end
