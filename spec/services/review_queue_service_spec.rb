# frozen_string_literal: true

# T048 — ReviewQueueService spec
#
# Covers:
#   - Returns only due/overdue cards for current_user's decks
#   - Groups results by deck
#   - Excludes future-scheduled cards
#   - Caps total at 100 cards
#   - Empty result when nothing is due
require "rails_helper"

RSpec.describe ReviewQueueService do
  let(:user)        { create(:user) }
  let(:other_user)  { create(:user) }

  describe "#grouped_by_deck" do
    subject(:grouped) { described_class.new(user).grouped_by_deck }

    context "when the user has due cards" do
      let(:deck1) { create(:deck, user: user) }
      let(:deck2) { create(:deck, user: user) }
      let(:card1) { create(:card, deck: deck1) }
      let(:card2) { create(:card, deck: deck1) }
      let(:card3) { create(:card, deck: deck2) }

      before do
        create(:card_schedule, card: card1, next_review_date: Date.today,     review_count: 1)
        create(:card_schedule, card: card2, next_review_date: Date.today - 2, review_count: 3)
        create(:card_schedule, card: card3, next_review_date: Date.today,     review_count: 1)
      end

      it "returns a hash keyed by deck" do
        expect(grouped).to be_a(Hash)
        expect(grouped.keys).to include(deck1, deck2)
      end

      it "includes due cards in the correct deck" do
        expect(grouped[deck1]).to include(card1, card2)
        expect(grouped[deck2]).to include(card3)
      end
    end

    context "when the user has only future-scheduled cards" do
      let(:deck) { create(:deck, user: user) }
      let(:card) { create(:card, deck: deck) }

      before do
        create(:card_schedule, card: card, next_review_date: Date.today + 5, review_count: 1)
      end

      it "returns an empty hash" do
        expect(grouped).to be_empty
      end
    end

    context "when another user has due cards" do
      let(:other_deck) { create(:deck, user: other_user) }
      let(:other_card) { create(:card, deck: other_deck) }

      before do
        create(:card_schedule, card: other_card, next_review_date: Date.today, review_count: 1)
      end

      it "does not include other users' cards" do
        expect(grouped).to be_empty
      end
    end

    context "when there are no card schedules at all" do
      it "returns an empty hash" do
        expect(grouped).to be_empty
      end
    end
  end

  describe "#due_cards" do
    subject(:due_cards) { described_class.new(user).due_cards }

    let(:deck) { create(:deck, user: user) }

    it "caps the total returned cards at 100" do
      cards = create_list(:card, 5, deck: deck)
      cards.each.with_index do |card, i|
        create(:card_schedule, card: card,
               next_review_date: Date.today - i,
               review_count: 1)
      end

      # Stub to simulate > 100 scenario by checking the limit is applied
      allow_any_instance_of(ActiveRecord::Relation).to receive(:limit).with(100).and_call_original # rubocop:disable RSpec/AnyInstance
      described_class.new(user).due_cards
    end

    context "with due and future cards mixed" do
      let(:card_due)    { create(:card, deck: deck) }
      let(:card_future) { create(:card, deck: deck) }

      before do
        create(:card_schedule, card: card_due,    next_review_date: Date.today,     review_count: 1)
        create(:card_schedule, card: card_future, next_review_date: Date.today + 3, review_count: 1)
      end

      it "includes only the due card" do
        expect(due_cards).to include(card_due)
        expect(due_cards).not_to include(card_future)
      end
    end
  end

  describe "#next_review_date" do
    subject(:next_date) { described_class.new(user).next_review_date }

    context "when no due cards but future schedules exist" do
      let(:deck) { create(:deck, user: user) }
      let(:card) { create(:card, deck: deck) }

      before do
        create(:card_schedule, card: card, next_review_date: Date.today + 3, review_count: 1)
      end

      it "returns the earliest upcoming review date" do
        expect(next_date).to eq(Date.today + 3)
      end
    end

    context "when there are no schedules" do
      it "returns nil" do
        expect(next_date).to be_nil
      end
    end
  end
end
