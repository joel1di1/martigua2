describe User do

  it { should validate_presence_of :email }
  it { should have_db_column :first_name }
  it { should have_db_column :last_name }
  it { should have_db_column :nickname }
  it { should have_db_column :phone_number }

  describe 'authentication token should be generated' do
    subject { create :user, authentication_token: nil }

    its(:authentication_token) { should_not be_nil }
    its(:id) { should_not be_nil }
  end

end
