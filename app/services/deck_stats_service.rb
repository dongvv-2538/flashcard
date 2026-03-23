# frozen_string_literal: true

# T061 — DeckStatsService
#
# Given a deck and user, returns a stats hash:
#   {
#     total:     Integer,  # total cards in the deck
#     new:       Integer,  # cards with no CardSchedule (never reviewed)
#     due_today: Integer,  # cards due today or overdue
#     learned:   Integer   # cards with interval_days > 1 (graduated from daily review)
#   }
#
# Usage:
#   stats = DeckStatsService.new(deck: deck, user: current_user).call
class DeckStatsService
  def initialize(deck:, user:)
    @deck = deck
    @user = user
  end

  def call
    cards        = @deck.cards
    card_ids     = cards.pluck(:id)

    return zero_stats if card_ids.empty?

    schedules = CardSchedule.where(card_id: card_ids)
    scheduled_ids = schedules.pluck(:card_id)

    total     = card_ids.size
    new_count = card_ids.size - scheduled_ids.size
    due_today = schedules.due_today.count
    learned   = schedules.where('interval_days > 1').count

    { total: total, new: new_count, due_today: due_today, learned: learned }
  end

  private

  def zero_stats
    { total: 0, new: 0, due_today: 0, learned: 0 }
  end
end
