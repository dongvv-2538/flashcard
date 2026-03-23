# frozen_string_literal: true

# T060 — Stats system spec
#
# Covers:
#   - Deck stats panel renders on deck show page
#   - Counts update correctly after completing a study session
require 'rails_helper'

RSpec.describe 'Deck Stats', type: :system do
  before do
    driven_by(:rack_test)
    visit new_session_path
    fill_in 'Username', with: user.username
    fill_in 'Password', with: 'password123'
    click_button 'Log in'
  end

  let(:user) { create(:user) }
  let(:deck) { create(:deck, user: user, name: 'German') }

  describe 'deck show page stats panel' do
    context 'with cards in various states' do
      let!(:new_card1)    { create(:card, deck: deck, front: 'Hallo', back: 'Hello') }
      let!(:new_card2)    { create(:card, deck: deck, front: 'Danke', back: 'Thanks') }
      let!(:due_card)     { create(:card, deck: deck, front: 'Bitte', back: 'Please') }
      let!(:learned_card) { create(:card, deck: deck, front: 'Ja', back: 'Yes') }

      before do
        create(:card_schedule, card: due_card,
                               next_review_date: Time.zone.today, review_count: 1,
                               interval_days: 1, ease_factor: 2.5)
        create(:card_schedule, card: learned_card,
                               next_review_date: Time.zone.today + 5, review_count: 3,
                               interval_days: 5, ease_factor: 2.5)
      end

      it 'shows the total card count' do
        visit deck_path(deck)

        within('.deck-stats') do
          expect(page).to have_content('4')   # total
        end
      end

      it 'shows the new card count' do
        visit deck_path(deck)

        within('.deck-stats') do
          expect(page).to have_content('2')   # new
        end
      end

      it 'shows the due today count' do
        visit deck_path(deck)

        within('.deck-stats') do
          expect(page).to have_content('Due Today')
          expect(page).to have_content('1') # due_today = 1
        end
      end

      it 'shows the learned count' do
        visit deck_path(deck)

        within('.deck-stats') do
          expect(page).to have_content('Learned')
          expect(page).to have_content('1') # learned = 1
        end
      end
    end
  end

  describe 'stats update after completing a session' do
    let!(:card) { create(:card, deck: deck, front: 'Nein', back: 'No') }

    it 'shows 0 new cards after the card has been scheduled' do
      # Before any schedule: card is new
      visit deck_path(deck)
      within('.deck-stats') do
        expect(page).to have_content('1') # total = 1
      end

      # Simulate a completed rating by creating the CardSchedule directly
      create(:card_schedule, card: card, next_review_date: Time.zone.today + 1,
                             review_count: 1, interval_days: 1, ease_factor: 2.5)

      # Revisit deck — stats re-fetched fresh (no cache)
      visit deck_path(deck)
      within('.deck-stats') do
        expect(page).to have_content('0') # new count = 0 (card is now scheduled)
      end
    end
  end
end
