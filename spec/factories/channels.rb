# frozen_string_literal: true

FactoryBot.define do
  factory :channel do
    section { nil }
    name { 'MyString' }
    private { false }
    system { false }
  end
end
