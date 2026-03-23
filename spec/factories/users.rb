# frozen_string_literal: true

# T016 — User factory
FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    password { 'password123' }
    # Dynamically match password so overriding password also updates confirmation
    password_confirmation { password }
  end
end
