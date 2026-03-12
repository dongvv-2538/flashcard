# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Decks", type: :system do
  before { driven_by(:rack_test) }

  let(:user) { create(:user) }

  before do
    # Log in
    visit new_session_path
    fill_in "Username", with: user.username
    fill_in "Password", with: "password123"
    click_button "Log in"
  end

  describe "index" do
    it "shows decks belonging to current user" do
      create(:deck, user: user, name: "Japanese")
      create(:deck, name: "Other user's deck") # different user

      visit decks_path

      expect(page).to have_content("Japanese")
      expect(page).not_to have_content("Other user's deck")
    end

    it "shows card count for each deck" do
      deck = create(:deck, user: user, name: "Spanish")
      create_list(:card, 3, deck: deck)

      visit decks_path

      expect(page).to have_content("3")
    end
  end

  describe "create" do
    it "creates a new deck" do
      visit new_deck_path

      fill_in "Name", with: "French Vocabulary"
      fill_in "Description", with: "Basic French words"
      click_button "Create Deck"

      expect(page).to have_content("French Vocabulary")
      expect(page).to have_content("Deck was successfully created")
    end

    it "shows errors for invalid deck" do
      visit new_deck_path

      fill_in "Name", with: ""
      click_button "Create Deck"

      expect(page).to have_content("error")
    end
  end

  describe "edit" do
    it "updates a deck" do
      deck = create(:deck, user: user, name: "Old Name")

      visit edit_deck_path(deck)
      fill_in "Name", with: "New Name"
      click_button "Update Deck"

      expect(page).to have_content("New Name")
      expect(page).to have_content("Deck was successfully updated")
    end
  end

  describe "delete" do
    it "deletes a deck and its cards" do
      deck = create(:deck, user: user, name: "To Delete")
      create(:card, deck: deck)

      visit decks_path
      # Find the delete button for this deck
      within find("li", text: "To Delete") do
        click_button "Delete"
      end

      expect(page).not_to have_content("To Delete")
      expect(Card.count).to eq(0)
    end
  end
end
