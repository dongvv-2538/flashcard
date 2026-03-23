# frozen_string_literal: true

# T070 — Quickstart smoke test
#
# End-to-end smoke test covering the full happy path:
#   Register → Create Deck → Add 5 Cards → Run Session (rate all Good)
#   → travel_to next day → Review Queue shows those 5 cards as due
#
# Uses ActiveSupport::Testing::TimeHelpers (included in rails_helper) and
# Capybara rack_test (no JS required for form interactions).
#
# rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
# (Smoke test intentionally covers the full user journey in one example)
require 'rails_helper'

RSpec.describe 'Quickstart smoke test', type: :system do
  before { driven_by(:rack_test) }

  def rate(label)
    find_button(label, visible: :all).click
  end

  it 'full flow: register → deck → cards → session → next-day review queue' do
    # ── 1. Register ──────────────────────────────────────────────────────────
    visit new_user_path
    fill_in 'Username', with: 'smoketest'
    fill_in 'Password', with: 'password123'
    fill_in 'Password confirmation', with: 'password123'
    click_button 'Register'

    expect(page).to have_content('smoketest')

    # ── 2. Create a deck ─────────────────────────────────────────────────────
    visit new_deck_path
    fill_in 'Name', with: 'Japanese Vocab'
    click_button 'Create Deck'

    expect(page).to have_content('Japanese Vocab')
    deck = Deck.find_by!(name: 'Japanese Vocab')

    # ── 3. Add 5 cards ───────────────────────────────────────────────────────
    words = [
      %w[猫 Cat], %w[犬 Dog], %w[魚 Fish], %w[鳥 Bird], %w[馬 Horse]
    ]
    words.each do |(front, back)|
      visit new_deck_card_path(deck)
      fill_in 'Front', with: front
      fill_in 'Back', with: back
      click_button 'Create Card'
    end

    visit deck_path(deck)
    expect(page).to have_content('5')

    # ── 4. Run a full study session (rate all Good) ───────────────────────────
    click_button 'Start Session'
    5.times { rate('Good') }

    expect(page).to have_content('Session Complete')
    expect(page).to have_content('5')

    # Confirm CardSchedules were created (interval_days = 1 for Good on new card)
    expect(CardSchedule.count).to eq(5)

    # ── 5. Travel to the next day → review queue shows all 5 cards as due ────
    travel_to(2.days.from_now) do
      visit reviews_path

      expect(page).to have_content('Japanese Vocab')
      expect(page).to have_content('5')
      expect(page).to have_button('Start Review')
    end
  end
end
# rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
