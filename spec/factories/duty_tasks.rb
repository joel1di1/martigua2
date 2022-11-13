# frozen_string_literal: true

FactoryBot.define do
  factory :duty_task do
    key { DutyTask::TASKS.keys.sample }
    user
    realised_at { Time.current }
    club
  end
end
