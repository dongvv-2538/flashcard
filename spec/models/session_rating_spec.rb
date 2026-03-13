# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionRating, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:study_session) }
    it { is_expected.to belong_to(:card) }
  end

  describe "enums" do
    it "defines again, hard, good, easy ratings" do
      expect(SessionRating.ratings).to include(
        "again" => 0,
        "hard"  => 1,
        "good"  => 2,
        "easy"  => 3
      )
    end

    it "allows again rating" do
      rating = build(:session_rating, rating: :again)
      expect(rating).to be_again
    end

    it "allows hard rating" do
      rating = build(:session_rating, rating: :hard)
      expect(rating).to be_hard
    end

    it "allows good rating" do
      rating = build(:session_rating, rating: :good)
      expect(rating).to be_good
    end

    it "allows easy rating" do
      rating = build(:session_rating, rating: :easy)
      expect(rating).to be_easy
    end
  end

  describe "validations" do
    subject { build(:session_rating) }

    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "requires a study_session" do
      subject.study_session = nil
      expect(subject).not_to be_valid
    end

    it "requires a card" do
      subject.card = nil
      expect(subject).not_to be_valid
    end

    it "requires a rating" do
      subject.rating = nil
      expect(subject).not_to be_valid
    end
  end

  describe "reviewed_at" do
    it "records when the review happened" do
      timestamp = 1.hour.ago
      rating = create(:session_rating, reviewed_at: timestamp)
      expect(rating.reviewed_at).to be_within(1.second).of(timestamp)
    end
  end

  describe "scopes" do
    describe ".by_rating" do
      it "filters records by a given rating" do
        good_rating  = create(:session_rating, rating: :good)
        again_rating = create(:session_rating, rating: :again)

        expect(SessionRating.where(rating: :good)).to include(good_rating)
        expect(SessionRating.where(rating: :good)).not_to include(again_rating)
      end
    end
  end
end
