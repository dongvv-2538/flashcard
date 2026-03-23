# frozen_string_literal: true

# T047 — CardSchedule model spec
#
# Covers:
#   - Associations and validations
#   - Scopes: due_today, overdue, new_cards
require 'rails_helper'

RSpec.describe CardSchedule, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:card) }
  end

  describe 'validations' do
    subject { build(:card_schedule) }

    it { is_expected.to validate_presence_of(:next_review_date) }
    it { is_expected.to validate_presence_of(:interval_days) }
    it { is_expected.to validate_presence_of(:ease_factor) }
    it { is_expected.to validate_numericality_of(:interval_days).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:ease_factor).is_greater_than_or_equal_to(1.3) }
    it { is_expected.to validate_uniqueness_of(:card_id) }
  end

  describe 'scopes' do
    let(:user)  { create(:user) }
    let(:deck)  { create(:deck, user: user) }
    let(:card1) { create(:card, deck: deck) }
    let(:card2) { create(:card, deck: deck) }
    let(:card3) { create(:card, deck: deck) }
    let(:card4) { create(:card, deck: deck) }

    before do
      # Due today (scheduled for today)
      create(:card_schedule, card: card1, next_review_date: Time.zone.today, review_count: 1)
      # Overdue (scheduled yesterday)
      create(:card_schedule, card: card2, next_review_date: Time.zone.today - 1, review_count: 2)
      # Future (scheduled tomorrow)
      create(:card_schedule, card: card3, next_review_date: Time.zone.today + 1, review_count: 1)
      # New card (never reviewed, next_review_date today)
      create(:card_schedule, card: card4, next_review_date: Time.zone.today, review_count: 0)
    end

    describe '.due_today' do
      it 'includes cards scheduled for today' do
        expect(described_class.due_today).to include(described_class.find_by(card: card1))
      end

      it 'includes overdue cards (scheduled before today)' do
        expect(described_class.due_today).to include(described_class.find_by(card: card2))
      end

      it 'excludes cards scheduled for the future' do
        expect(described_class.due_today).not_to include(described_class.find_by(card: card3))
      end
    end

    describe '.overdue' do
      it 'includes cards scheduled before today' do
        expect(described_class.overdue).to include(described_class.find_by(card: card2))
      end

      it 'excludes cards scheduled for today' do
        expect(described_class.overdue).not_to include(described_class.find_by(card: card1))
      end

      it 'excludes future cards' do
        expect(described_class.overdue).not_to include(described_class.find_by(card: card3))
      end
    end

    describe '.new_cards' do
      it 'includes cards with review_count of 0' do
        expect(described_class.new_cards).to include(described_class.find_by(card: card4))
      end

      it 'excludes cards that have been reviewed' do
        expect(described_class.new_cards).not_to include(described_class.find_by(card: card1))
      end
    end
  end
end
