# frozen_string_literal: true

FactoryBot.define do
  factory :session_rating do
    association :study_session
    association :card
    rating { :good }
    reviewed_at { Time.current }
  end
end
