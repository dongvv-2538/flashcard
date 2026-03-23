# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StudySession, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:deck) }
    it { is_expected.to have_many(:session_ratings) }
  end

  describe 'enums' do
    it 'defines full_deck and review_due session types' do
      expect(described_class.session_types).to include('full_deck' => 0, 'review_due' => 1)
    end

    it 'defaults to full_deck session type' do
      user = build(:user)
      deck = build(:deck, user: user)
      session = described_class.new(user: user, deck: deck)

      expect(session.session_type).to eq('full_deck')
    end

    it 'allows review_due session type' do
      study_session = build(:study_session, session_type: :review_due)

      expect(study_session).to be_review_due
    end

    it 'allows full_deck session type' do
      study_session = build(:study_session, session_type: :full_deck)

      expect(study_session).to be_full_deck
    end
  end

  describe 'validations' do
    subject { build(:study_session) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires a user' do
      subject.user = nil
      expect(subject).not_to be_valid
    end

    it 'requires a deck' do
      subject.deck = nil
      expect(subject).not_to be_valid
    end
  end

  describe 'scopes' do
    describe '.completed' do
      it 'returns sessions that have an ended_at timestamp' do
        user = create(:user)
        deck = create(:deck, user: user)
        completed   = create(:study_session, user: user, deck: deck, ended_at: 1.minute.ago, cards_reviewed_count: 1)
        incomplete  = create(:study_session, user: user, deck: deck, ended_at: nil)

        expect(described_class.completed).to include(completed)
        expect(described_class.completed).not_to include(incomplete)
      end

      it 'returns sessions where cards_reviewed_count is positive' do
        user = create(:user)
        deck = create(:deck, user: user)
        reviewed    = create(:study_session, user: user, deck: deck, ended_at: 1.minute.ago, cards_reviewed_count: 3)
        zero_review = create(:study_session, user: user, deck: deck, ended_at: 1.minute.ago, cards_reviewed_count: 0)

        expect(described_class.completed).to include(reviewed)
        expect(described_class.completed).not_to include(zero_review)
      end
    end
  end

  describe '#completed?' do
    it 'returns true when ended_at is present and cards_reviewed_count > 0' do
      study_session = build(:study_session, ended_at: Time.current, cards_reviewed_count: 5)

      expect(study_session.completed?).to be true
    end

    it 'returns false when ended_at is nil' do
      study_session = build(:study_session, ended_at: nil, cards_reviewed_count: 5)

      expect(study_session.completed?).to be false
    end

    it 'returns false when cards_reviewed_count is zero' do
      study_session = build(:study_session, ended_at: Time.current, cards_reviewed_count: 0)

      expect(study_session.completed?).to be false
    end
  end
end
