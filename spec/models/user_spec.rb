describe User do

  it { should validate_presence_of :email }
  it { should have_db_column :first_name }
  it { should have_db_column :last_name }
  it { should have_db_column :nickname }
  it { should have_db_column :phone_number }
  it { should have_many :club_admin_roles }
  it { should have_many :participations }
  it { should have_many :sections }
  it { should have_many :training_presences }

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
    context 'user with two participations on one section' do
      let(:section) { create :section }
      let!(:participation_1) { create :participation, user: user, section: section, role: Participation::PLAYER}
      let!(:participation_2) { create :participation, user: user, section: section, role: Participation::COACH}
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

  describe '#present_for!' do
    context 'with one training' do
      let(:training) { create :training }

      let(:set_presence) { user.present_for!(training) }

      it { expect{set_presence}.to change{TrainingPresence.count}.by(1) }

      describe 'user availability' do
        before { set_presence }

        it { expect(user.is_present_for?(training)).to be_truthy }
      end
    end
    context 'with two trainings' do
      let(:training_1) { create :training }
      let(:training_2) { create :training }

      context 'passed as array' do
        let(:set_presence) { user.present_for!([training_1, training_2]) }

        it { expect{set_presence}.to change{TrainingPresence.count}.by(2) }
      end
      context 'passed as params' do
        let(:set_presence) { user.present_for!(training_1, training_2) }

        it { expect{set_presence}.to change{TrainingPresence.count}.by(2) }
      end
    end
  end

  describe 'is_present_for?' do
    let(:training) { create :training }

    context 'without any response' do
      it { expect(user.is_present_for?(training)).to be_nil }
    end

    context 'without a nil response' do
      let!(:training_presence) { create :training_presence, training: training, user: user, present: nil }

      it { expect(user.is_present_for?(training)).to be_nil }
    end
    context 'without a true response' do
      let!(:training_presence) { create :training_presence, training: training, user: user, present: true }

      it { expect(user.is_present_for?(training)).to be_truthy }
    end
    context 'without a false response' do
      let!(:training_presence) { create :training_presence, training: training, user: user, present: false }

      it { expect(user.is_present_for?(training)).to be_falsy }
    end
  end

end
