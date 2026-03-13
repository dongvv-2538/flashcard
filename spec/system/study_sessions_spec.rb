# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Study Sessions", type: :system do
  before { driven_by(:rack_test) }

  let(:user) { create(:user) }
  let(:deck) { create(:deck, user: user) }

  before do
    visit new_session_path
    fill_in "Username", with: user.username
    fill_in "Password", with: "password123"
    click_button "Log in"
  end

  describe "starting a session" do
    context "when the deck has cards" do
      before { create_list(:card, 3, deck: deck) }

      it "creates a new study session and shows the first card" do
        visit deck_path(deck)
        click_button "Start Session"

        expect(page).to have_content("Card 1 of 3")
      end

      it "shows the card front on the session page" do
        card = create(:card, deck: deck, front: "What is 2+2?", back: "4")

        post deck_study_sessions_path(deck)
        visit deck_study_session_path(deck, StudySession.last)

        expect(page).to have_content("What is 2+2?")
      end
    end

    context "when the deck has no cards" do
      it "redirects back with a notice" do
        visit deck_path(deck)
        click_button "Start Session"

        expect(page).to have_content("no cards")
      end
    end
  end

  describe "full session flow" do
    let!(:card1) { create(:card, deck: deck, front: "Q1", back: "A1") }
    let!(:card2) { create(:card, deck: deck, front: "Q2", back: "A2") }
    let!(:card3) { create(:card, deck: deck, front: "Q3", back: "A3") }

    def start_session
      visit deck_path(deck)
      click_button "Start Session"
    end

    it "displays the first card front after starting" do
      start_session

      expect(page).to have_content("Q1")
      expect(page).to have_button("Again")
      expect(page).to have_button("Hard")
      expect(page).to have_button("Good")
      expect(page).to have_button("Easy")
    end

    it "advances to the next card after rating Good" do
      start_session

      click_button "Good"

      expect(page).to have_content("Q2")
    end

    it "completes the session after rating all cards" do
      start_session

      click_button "Good"
      click_button "Good"
      click_button "Good"

      expect(page).to have_content("Session Complete")
      expect(page).to have_content("3")
    end

    it "shows a summary with rating breakdown after completion" do
      start_session

      click_button "Good"
      click_button "Easy"
      click_button "Hard"

      expect(page).to have_content("Session Complete")
      expect(page).to have_content("Good")
      expect(page).to have_content("Easy")
      expect(page).to have_content("Hard")
    end

    it "re-queues a card rated Again and shows it later" do
      start_session

      # Rate card1 "Again" — it should re-appear after remaining cards
      click_button "Again"

      # card2 should appear next
      expect(page).to have_content("Q2")

      click_button "Good"

      # card3 should appear next
      expect(page).to have_content("Q3")

      click_button "Good"

      # card1 re-appears due to Again re-queue
      expect(page).to have_content("Q1")

      click_button "Good"

      expect(page).to have_content("Session Complete")
    end

    it "caps Again re-queue at 3 times and then ends session" do
      single_card_deck = create(:deck, user: user)
      card = create(:card, deck: single_card_deck, front: "Tough Q", back: "Tough A")

      visit deck_path(single_card_deck)
      click_button "Start Session"

      # Rate "Again" 3 times (max re-queue)
      3.times { click_button "Again" }

      # 4th time card appears, rating it completes the session
      click_button "Again"

      expect(page).to have_content("Session Complete")
    end

    it "shows progress indicator for cards remaining" do
      start_session

      expect(page).to have_content("Card 1 of 3")

      click_button "Good"

      expect(page).to have_content("Card 2 of 3")
    end

    it "has a Back to Deck link in the summary" do
      start_session

      click_button "Good"
      click_button "Good"
      click_button "Good"

      expect(page).to have_link("Back to Deck")
    end
  end
end
