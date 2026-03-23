# frozen_string_literal: true

# T054 — ReviewQueueService
#
# Aggregates all due/overdue CardSchedule records for a given user,
# grouped by deck. Caps the total at 100 cards to keep sessions manageable.
#
# Usage:
#   service = ReviewQueueService.new(current_user)
#   service.grouped_by_deck   # => { deck => [card, ...], ... }
#   service.due_cards          # => [card, ...]           (flat, capped at 100)
#   service.next_review_date   # => Date | nil            (earliest future date)
class ReviewQueueService
  MAX_CARDS = 100

  def initialize(user)
    @user = user
  end

  # Returns due/overdue cards grouped by their deck.
  # @return [Hash{Deck => Array<Card>}]
  def grouped_by_deck
    due_cards.group_by(&:deck)
  end

  # Returns all due/overdue cards for the user, capped at MAX_CARDS.
  # @return [Array<Card>]
  def due_cards
    @due_cards ||= fetch_due_cards
  end

  # Returns the earliest upcoming (future) review date across all of the
  # user's card schedules, or nil if no schedules exist.
  # @return [Date, nil]
  def next_review_date
    deck_ids = @user.decks.pluck(:id)
    return nil if deck_ids.empty?

    CardSchedule
      .where('next_review_date > ?', Time.zone.today)
      .joins(:card)
      .where(cards: { deck_id: deck_ids })
      .minimum(:next_review_date)
  end

  private

  def fetch_due_cards(deck_ids = @user.decks.pluck(:id))
    return [] if deck_ids.empty?

    CardSchedule
      .due_today
      .joins(:card)
      .where(cards: { deck_id: deck_ids })
      .includes(card: :deck)
      .order(:next_review_date)
      .limit(MAX_CARDS)
      .map(&:card)
  end
end
