# frozen_string_literal: true

# T051 — CardSchedule model
#
# Persists the SM-2 spaced repetition state for a single card.
# A card_schedule is created (or updated) every time the learner rates a card
# via the SM2Scheduler service.
#
# Scopes:
#   due_today  — next_review_date <= today (includes overdue)
#   overdue    — next_review_date <  today (strictly before today)
#   new_cards  — review_count == 0 (never reviewed)
class CardSchedule < ApplicationRecord
  belongs_to :card

  validates :next_review_date, presence: true
  validates :interval_days,    presence: true,
                               numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :ease_factor,      presence: true,
                               numericality: { greater_than_or_equal_to: 1.3 }
  validates :review_count,     presence: true,
                               numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :card_id,          uniqueness: true

  scope :due_today,  -> { where(next_review_date: ..Time.zone.today) }
  scope :overdue,    -> { where(next_review_date: ...Time.zone.today) }
  scope :new_cards,  -> { where(review_count: 0) }
end
