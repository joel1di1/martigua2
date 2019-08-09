# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :club_admin_role do
    club
    user
    name { ClubAdminRole::ADMIN }
  end
end
