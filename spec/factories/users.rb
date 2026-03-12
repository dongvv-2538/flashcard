# frozen_string_literal: true

# T016 — User factory
FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
