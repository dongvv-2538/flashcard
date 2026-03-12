# frozen_string_literal: true

# T030 — Factories for Deck and Card
FactoryBot.define do
  factory :deck do
    association :user
    sequence(:name) { |n| "Deck #{n}" }
    description { "A test deck" }
  end
end
