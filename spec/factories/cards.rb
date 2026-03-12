# frozen_string_literal: true

FactoryBot.define do
  factory :card do
    association :deck
    sequence(:front) { |n| "Front #{n}" }
    sequence(:back)  { |n| "Back #{n}" }
  end
end
