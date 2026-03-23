# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cards', type: :system do
  before do
    driven_by(:rack_test)
    visit new_session_path
    fill_in 'Username', with: user.username
    fill_in 'Password', with: 'password123'
    click_button 'Log in'
  end

  let(:user) { create(:user) }
  let(:deck) { create(:deck, user: user) }

  describe 'index' do
    it 'lists cards in a deck' do
      create(:card, deck: deck, front: 'Hello', back: 'Hola')
      create(:card, deck: deck, front: 'Goodbye', back: 'Adiós')

      visit deck_cards_path(deck)

      expect(page).to have_content('Hello')
      expect(page).to have_content('Goodbye')
    end
  end

  describe 'create' do
    it 'adds a new card to the deck' do
      visit new_deck_card_path(deck)

      fill_in 'Front', with: 'Apple'
      fill_in 'Back', with: 'Manzana'
      click_button 'Create Card'

      expect(page).to have_content('Apple')
      expect(page).to have_content('Card was successfully created')
    end

    it 'shows errors for invalid card' do
      visit new_deck_card_path(deck)

      fill_in 'Front', with: ''
      fill_in 'Back', with: ''
      click_button 'Create Card'

      expect(page).to have_content('error')
    end
  end

  describe 'edit' do
    it 'updates a card' do
      card = create(:card, deck: deck, front: 'Old front', back: 'Old back')

      visit edit_deck_card_path(deck, card)
      fill_in 'Front', with: 'New front'
      click_button 'Update Card'

      expect(page).to have_content('New front')
      expect(page).to have_content('Card was successfully updated')
    end
  end

  describe 'delete' do
    it 'removes a card' do
      create(:card, deck: deck, front: 'To remove', back: 'Quitar')

      visit deck_cards_path(deck)
      within find('tr', text: 'To remove') do
        click_button 'Delete'
      end

      expect(page).not_to have_content('To remove')
    end
  end
end
