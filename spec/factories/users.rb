FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone_number { Faker::PhoneNumber.cell_phone }
    email { Faker::Internet.email }
    password { Faker::Lorem.characters(6) }

    trait :club_admin do
      after(:create) do |user|
        create :club_admin_role, user: user
      end
    end
  end

  factory :one_section_player, parent: :user do
    after(:create) do |user|
      create :participation, user: user
    end
  end
end
