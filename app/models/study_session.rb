# frozen_string_literal: true

# T037 — StudySession model
# Represents a single practice session on a deck.
# session_type: full_deck (0) = all cards; review_due (1) = only due/overdue cards
class StudySession < ApplicationRecord
  belongs_to :user
  belongs_to :deck
  has_many :session_ratings, dependent: :destroy

  enum :session_type, { full_deck: 0, review_due: 1 }, default: :full_deck

  validates :started_at, presence: true
  validates :cards_reviewed_count, numericality: { greater_than_or_equal_to: 0 }

  # A session is completed when it has ended AND at least one card was reviewed.
  scope :completed, -> { where.not(ended_at: nil).where('cards_reviewed_count > 0') }

  def completed?
    ended_at.present? && cards_reviewed_count.positive?
  end
end
