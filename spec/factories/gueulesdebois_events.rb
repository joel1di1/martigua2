# frozen_string_literal: true

FactoryBot.define do
  factory :gueulesdebois_event do
    sequence(:title) { |n| "AMUSE-GUEULE ##{n} : accueil et présentation de l'atelier partagé" }
    sequence(:event_url) { |n| "/event/amuse-gueule-#{n}/register" }
  end
end
