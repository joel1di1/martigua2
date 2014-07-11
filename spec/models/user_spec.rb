describe User do

  it { should validate_presence_of :email }
  it { should have_db_column :first_name }
  it { should have_db_column :last_name }
  it { should have_db_column :nickname }
  it { should have_db_column :phone_number }

end
