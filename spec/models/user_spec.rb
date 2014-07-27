describe User do

  it { should validate_presence_of :email }
  it { should have_db_column :first_name }
  it { should have_db_column :last_name }
  it { should have_db_column :nickname }
  it { should have_db_column :phone_number }
  it { should have_many :club_admin_roles }
  it { should have_many :participations }
  it { should have_many :sections }
  it { should have_many :training_availabilities }

  let(:user) { create :user }

  describe 'authentication token should be generated' do
    subject { create :user, authentication_token: nil }

    its(:authentication_token) { should_not be_nil }
    its(:id) { should_not be_nil }
  end

  describe '#has_only_one_section?' do
    subject { user.has_only_one_section? }

    context 'user with no section' do
      it { should eq false }
    end
    context 'user with two sections' do
      let!(:participation_1) { create :participation, user: user }
      let!(:participation_2) { create :participation, user: user }
      it { should eq false }
    end
    context 'user with one section' do
      let!(:participation_1) { create :participation, user: user }
      it { should eq true }
    end
  end

  describe '#is_coach_of?' do
    let(:section) { create :section }

    subject { user.is_coach_of?(section) }

    context 'with a user not in the section' do
      it { should eq false }
    end
    context 'with a player of the section' do
      before { section.add_player!(user) }
      
      it { should eq false }
    end
    context 'with a coach of the section' do
      before { section.add_coach!(user) }
      
      it { should eq true }
    end
  end
  describe '#is_player_of?' do
    let(:section) { create :section }

    subject { user.is_player_of?(section) }

    context 'with a user not in the section' do
      it { should eq false }
    end
    context 'with a player of the section' do
      before { section.add_player!(user) }
      
      it { should eq true }
    end
    context 'with a coach of the section' do
      before { section.add_coach!(user) }
      
      it { should eq false }
    end
  end

  describe '#display_participations' do

    let(:display) { user.display_participations }

    context 'with one participation' do
      let!(:participation) { create :participation, user: user }

      it { expect(display).to include(participation.section.club.name) }
      it { expect(display).to include(participation.section.name) }
      it { expect(display).to include(participation.role) }
      it { expect(display).to include(participation.season.to_s) }
    end

  end

  describe '#available_for!' do
    context 'with one training' do
      let(:training) { create :training }

      let(:set_availability) { user.available_for!(training) }

      it { expect{set_availability}.to change{TrainingAvailability.count}.by(1) }

      describe 'user availability' do
        before { set_availability }

        it { expect(user.is_available_for?(training)).to be_truthy }
      end
    end
    context 'with two trainings' do
      let(:training_1) { create :training }
      let(:training_2) { create :training }

      context 'passed as array' do
        let(:set_availability) { user.available_for!([training_1, training_2]) }

        it { expect{set_availability}.to change{TrainingAvailability.count}.by(2) }
      end
      context 'passed as params' do
        let(:set_availability) { user.available_for!(training_1, training_2) }

        it { expect{set_availability}.to change{TrainingAvailability.count}.by(2) }
      end
    end
  end

end
