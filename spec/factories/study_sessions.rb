# frozen_string_literal: true

FactoryBot.define do
  factory :study_session do
    association :user
    association :deck
    session_type { :full_deck }
    started_at { Time.current }
    ended_at { nil }
    cards_reviewed_count { 0 }
  end
end
