FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone_number { Faker::PhoneNumber.cell_phone }
    email { Faker::Internet.email }
    password { Faker::Lorem.characters(6) }

    trait :section_coach do
      after(:create) do |user|
        create :participation, :coach, user: user
      end
    end

    transient do
      with_section nil
      with_section_as_coach nil
      with_group nil
    end

    after(:create) do |user, evaluator|
      evaluator.with_section.add_player!(user) if evaluator.with_section
      evaluator.with_section_as_coach.add_coach!(user) if evaluator.with_section_as_coach
      evaluator.with_group.add_user!(user) if evaluator.with_group
    end
  end

  factory :one_section_player, parent: :user do
    after(:create) do |user|
      create :participation, :player, user: user
    end
  end

  factory :coach, parent: :user do
    after(:create) do |coach|
      create :participation, :coach, user: coach
      2.times do
        section = coach.sections.first
        section.teams << create(:team, club: section.club)
      end
    end
  end
end
