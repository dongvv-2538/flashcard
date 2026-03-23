# frozen_string_literal: true

# T058 — FactoryBot factory for CardSchedule
FactoryBot.define do
  factory :card_schedule do
    association :card
    next_review_date { Date.today }
    interval_days    { 0 }
    ease_factor      { 2.5 }
    review_count     { 0 }
    last_reviewed_at { nil }
  end
end
