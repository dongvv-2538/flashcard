# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication", type: :system do
  before { driven_by(:rack_test) }

  describe "Registration" do
    it "allows a new user to register" do
      visit new_user_path

      fill_in "Username", with: "alice"
      fill_in "Password", with: "password123"
      fill_in "Password confirmation", with: "password123"
      click_button "Register"

      expect(page).to have_content("Welcome, alice")
      expect(page).to have_content("alice")
    end

    it "shows errors for invalid registration" do
      visit new_user_path

      fill_in "Username", with: ""
      fill_in "Password", with: "short"
      fill_in "Password confirmation", with: "mismatch"
      click_button "Register"

      expect(page).to have_content("error")
    end

    it "shows error when username is already taken" do
      create(:user, username: "alice")

      visit new_user_path
      fill_in "Username", with: "alice"
      fill_in "Password", with: "password123"
      fill_in "Password confirmation", with: "password123"
      click_button "Register"

      expect(page).to have_content("error")
    end
  end

  describe "Login" do
    let!(:user) { create(:user, username: "bob", password: "secret123") }

    it "allows existing user to log in" do
      visit new_session_path

      fill_in "Username", with: "bob"
      fill_in "Password", with: "secret123"
      click_button "Log in"

      expect(page).to have_content("bob")
    end

    it "shows error for wrong credentials" do
      visit new_session_path

      fill_in "Username", with: "bob"
      fill_in "Password", with: "wrongpassword"
      click_button "Log in"

      expect(page).to have_content("Invalid username or password")
    end
  end

  describe "Logout" do
    it "allows user to log out" do
      user = create(:user, username: "carol", password: "secret123")

      visit new_session_path
      fill_in "Username", with: "carol"
      fill_in "Password", with: "secret123"
      click_button "Log in"

      click_link "Log out"

      expect(page).to have_link("Log in")
    end
  end

  describe "Protected routes" do
    it "redirects unauthenticated user to login" do
      visit decks_path

      expect(page).to have_current_path(new_session_path)
    end
  end
end
