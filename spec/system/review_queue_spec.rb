# frozen_string_literal: true

# T049 — Review queue system spec
#
# Covers:
#   - Due cards listed on the Review Queue page
#   - No-due-cards message with next scheduled date fallback
#   - Start review session from the queue
require "rails_helper"

RSpec.describe "Review Queue", type: :system do
  before { driven_by(:rack_test) }

  let(:user) { create(:user) }

  before do
    visit new_session_path
    fill_in "Username", with: user.username
    fill_in "Password", with: "password123"
    click_button "Log in"
  end

  describe "index page" do
    context "when the user has due cards" do
      let(:deck) { create(:deck, user: user, name: "Spanish Vocab") }
      let(:card1) { create(:card, deck: deck) }
      let(:card2) { create(:card, deck: deck) }

      before do
        create(:card_schedule, card: card1, next_review_date: Date.today,     review_count: 1)
        create(:card_schedule, card: card2, next_review_date: Date.today - 1, review_count: 2)
      end

      it "shows the deck name with its due card count" do
        visit reviews_path

        expect(page).to have_content("Spanish Vocab")
        expect(page).to have_content("2")
      end

      it "has a Start Review button for the deck" do
        visit reviews_path

        expect(page).to have_button("Start Review")
      end

      it "does not show a no-cards-due message" do
        visit reviews_path

        expect(page).not_to have_content("No cards due")
      end
    end

    context "when the user has no due cards but future schedules exist" do
      let(:deck) { create(:deck, user: user) }
      let(:card) { create(:card, deck: deck) }

      before do
        create(:card_schedule, card: card, next_review_date: Date.today + 3, review_count: 1)
      end

      it "shows a no-cards-due message" do
        visit reviews_path

        expect(page).to have_content("No cards due")
      end

      it "shows the next scheduled review date" do
        visit reviews_path

        expect(page).to have_content((Date.today + 3).strftime("%B %-d"))
      end
    end

    context "when the user has no cards at all" do
      it "shows a no-cards-due message" do
        visit reviews_path

        expect(page).to have_content("No cards due")
      end
    end

    context "when another user has due cards" do
      let(:other_user) { create(:user) }
      let(:other_deck) { create(:deck, user: other_user, name: "Other Deck") }
      let(:other_card) { create(:card, deck: other_deck) }

      before do
        create(:card_schedule, card: other_card, next_review_date: Date.today, review_count: 1)
      end

      it "does not show the other user's deck" do
        visit reviews_path

        expect(page).not_to have_content("Other Deck")
      end
    end
  end

  describe "starting a review session from the queue" do
    let(:deck)  { create(:deck, user: user, name: "French") }
    let(:card1) { create(:card, deck: deck, front: "Bonjour", back: "Hello") }
    let(:card2) { create(:card, deck: deck, front: "Merci", back: "Thank you") }

    before do
      create(:card_schedule, card: card1, next_review_date: Date.today,     review_count: 1)
      create(:card_schedule, card: card2, next_review_date: Date.today - 1, review_count: 2)
    end

    it "redirects to a study session showing the first due card" do
      visit reviews_path
      click_button "Start Review"

      expect(page).to have_content("Card 1 of")
      expect(page).to have_button("Show Answer")
    end
  end
end
