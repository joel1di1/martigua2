# frozen_string_literal: true

FactoryBot.define do
  factory :duty_task do
    key { :youth_training }
    user
    realised_at { Time.current }
  end
end
