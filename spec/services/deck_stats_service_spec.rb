# frozen_string_literal: true

# T059 — DeckStatsService spec
#
# Covers correct counts: total, new (unreviewed), due_today, learned (interval > 1)
require 'rails_helper'

RSpec.describe DeckStatsService do
  subject(:stats) { described_class.new(deck: deck, user: user).call }

  let(:user) { create(:user) }
  let(:deck) { create(:deck, user: user) }

  context 'with no cards' do
    it 'returns all zero counts' do
      expect(stats).to eq({ total: 0, new: 0, due_today: 0, learned: 0 })
    end
  end

  context 'with a mix of cards at different schedule states' do
    let!(:new_card1)     { create(:card, deck: deck) }
    let!(:new_card2)     { create(:card, deck: deck) }
    let!(:due_card)      { create(:card, deck: deck) }
    let!(:learned_card)  { create(:card, deck: deck) }
    let!(:future_card)   { create(:card, deck: deck) }

    before do
      # new_card1, new_card2 have NO card_schedule → counted as "new"

      # due_card: scheduled for today, reviewed once, interval 1 (not yet learned)
      create(:card_schedule, card: due_card, next_review_date: Time.zone.today,
                             review_count: 1, interval_days: 1, ease_factor: 2.5)

      # learned_card: scheduled tomorrow, interval > 1 day
      create(:card_schedule, card: learned_card, next_review_date: Time.zone.today + 5,
                             review_count: 3, interval_days: 5, ease_factor: 2.5)

      # future_card: scheduled tomorrow, interval 1 (not learned, not due)
      create(:card_schedule, card: future_card, next_review_date: Time.zone.today + 1,
                             review_count: 1, interval_days: 1, ease_factor: 2.5)
    end

    it 'counts total cards in the deck' do
      expect(stats[:total]).to eq(5)
    end

    it 'counts cards with no card_schedule as new' do
      expect(stats[:new]).to eq(2)
    end

    it 'counts cards due today or overdue' do
      expect(stats[:due_today]).to eq(1)
    end

    it 'counts cards with interval_days > 1 as learned' do
      expect(stats[:learned]).to eq(1)
    end
  end

  context "with cards belonging to a different user's deck" do
    let(:other_user)  { create(:user) }
    let(:other_deck)  { create(:deck, user: other_user) }
    let!(:other_card) { create(:card, deck: other_deck) }

    before do
      create(:card_schedule, card: other_card, next_review_date: Time.zone.today,
                             review_count: 1, interval_days: 1, ease_factor: 2.5)
    end

    it 'only counts cards in the requested deck' do
      expect(stats[:total]).to eq(0)
    end
  end

  context 'with an overdue card' do
    let!(:overdue_card) { create(:card, deck: deck) }

    before do
      create(:card_schedule, card: overdue_card,
                             next_review_date: Time.zone.today - 2,
                             review_count: 2, interval_days: 2, ease_factor: 2.5)
    end

    it 'includes overdue cards in due_today count' do
      expect(stats[:due_today]).to eq(1)
    end
  end
end
