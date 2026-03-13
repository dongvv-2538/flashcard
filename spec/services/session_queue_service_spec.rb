# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionQueueService do
  let(:deck) { create(:deck) }
  let(:card1) { create(:card, deck: deck, front: "Q1", back: "A1") }
  let(:card2) { create(:card, deck: deck, front: "Q2", back: "A2") }
  let(:card3) { create(:card, deck: deck, front: "Q3", back: "A3") }

  describe "#initialize" do
    it "loads all cards for the given deck in order" do
      card1; card2; card3  # materialize

      service = described_class.new(deck.cards)

      expect(service.total_count).to eq(3)
    end

    it "accepts an empty card list" do
      service = described_class.new([])

      expect(service.empty?).to be true
      expect(service.total_count).to eq(0)
    end
  end

  describe "#next_card" do
    it "returns the first card in the queue" do
      service = described_class.new([card1, card2])

      expect(service.next_card).to eq(card1)
    end

    it "returns nil when the queue is empty" do
      service = described_class.new([])

      expect(service.next_card).to be_nil
    end
  end

  describe "#advance!" do
    it "removes the current card after advancing" do
      service = described_class.new([card1, card2, card3])

      service.advance!(:good)

      expect(service.next_card).to eq(card2)
    end

    it "advances through all cards" do
      service = described_class.new([card1, card2, card3])

      service.advance!(:good)
      service.advance!(:easy)
      service.advance!(:hard)

      expect(service.empty?).to be true
    end
  end

  describe "Again re-queue" do
    it "re-queues a card to the end of the queue when rated Again" do
      service = described_class.new([card1, card2])

      service.advance!(:again)  # card1 rated Again → moves to end

      expect(service.next_card).to eq(card2)
    end

    it "card reappears after remaining cards when rated Again" do
      service = described_class.new([card1, card2, card3])

      service.advance!(:again)  # card1 → end

      expect(service.next_card).to eq(card2)
      service.advance!(:good)   # card2 done

      expect(service.next_card).to eq(card3)
      service.advance!(:good)   # card3 done

      expect(service.next_card).to eq(card1)  # card1 re-appears
    end

    it "caps re-queue at 3 times for the same card" do
      service = described_class.new([card1])

      service.advance!(:again)  # re-queue count = 1
      service.advance!(:again)  # re-queue count = 2
      service.advance!(:again)  # re-queue count = 3

      # 4th encounter: card should still be present for one final rating
      expect(service.next_card).to eq(card1)

      service.advance!(:again)  # count would be 4 — capped, card NOT re-queued

      expect(service.empty?).to be true
    end

    it "does not re-queue a card rated Again beyond the cap even if other cards remain" do
      service = described_class.new([card1, card2])

      3.times { service.advance!(:again) }  # card1 hits cap (3 re-queues done, next is final)
      # After 3 advances with Again, card1 has been re-queued 3 times.
      # On the 4th encounter (advance!(:again)) it must NOT be re-queued.
      service.advance!(:again)

      # Only card2 should remain
      expect(service.remaining_count).to eq(1)
      expect(service.next_card).to eq(card2)
    end
  end

  describe "#remaining_count" do
    it "decrements as cards are advanced with non-Again ratings" do
      service = described_class.new([card1, card2, card3])

      expect(service.remaining_count).to eq(3)
      service.advance!(:good)
      expect(service.remaining_count).to eq(2)
    end

    it "does not decrement when a card is re-queued with Again" do
      service = described_class.new([card1, card2])

      service.advance!(:again)

      expect(service.remaining_count).to eq(2)
    end
  end

  describe "#empty?" do
    it "returns false when cards remain" do
      service = described_class.new([card1])

      expect(service.empty?).to be false
    end

    it "returns true after all cards are completed" do
      service = described_class.new([card1])

      service.advance!(:good)

      expect(service.empty?).to be true
    end
  end

  describe "#to_session_state / .from_session_state" do
    it "round-trips queue state through a serialisable hash" do
      card1; card2; card3

      service = described_class.new([card1, card2, card3])
      service.advance!(:again)  # card1 re-queued once

      state = service.to_session_state

      restored = described_class.from_session_state(state)

      expect(restored.next_card.id).to eq(card2.id)
      expect(restored.total_count).to eq(service.total_count)
    end
  end
end
