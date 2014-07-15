# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :club_admin_role do
    club
    user
    name 'admin'
  end
end
