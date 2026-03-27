# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Study Sessions', type: :system do
  before do
    driven_by(:rack_test)
    visit new_session_path
    fill_in 'Username', with: user.username
    fill_in 'Password', with: 'password123'
    click_button 'Log in'
  end

  let(:user) { create(:user) }
  let(:deck) { create(:deck, user: user) }

  # In rack_test (no JS), the rating buttons are present in the DOM but hidden
  # via inline CSS (display:none) pending the JS card-flip interaction.
  # We click them with visible: :all so the server-side behaviour is fully tested.
  def rate(label)
    find_button(label, visible: :all).click
  end

  describe 'starting a session' do
    context 'when the deck has cards' do
      before { create_list(:card, 3, deck: deck) }

      it 'creates a new study session and shows the first card' do
        visit deck_path(deck)
        click_button 'Start Session'

        expect(page).to have_content('Card 1 of 3')
      end

      it 'shows the card front on the session page' do
        # Use a fresh deck with only one known card so it is shown first
        solo_deck = create(:deck, user: user)
        create(:card, deck: solo_deck, front: 'What is 2+2?', back: '4')

        visit deck_path(solo_deck)
        click_button 'Start Session'

        expect(page).to have_content('What is 2+2?')
      end
    end

    context 'when the deck has no cards' do
      it 'redirects back with a notice' do
        visit deck_path(deck)
        click_button 'Start Session'

        expect(page).to have_content('no cards')
      end
    end
  end

  describe 'full session flow' do
    let!(:card1) { create(:card, deck: deck, front: 'Q1', back: 'A1') }
    let!(:card2) { create(:card, deck: deck, front: 'Q2', back: 'A2') }
    let!(:card3) { create(:card, deck: deck, front: 'Q3', back: 'A3') }

    def start_session
      visit deck_path(deck)
      click_button 'Start Session'
    end

    it 'displays the first card front after starting' do
      start_session

      expect(page).to have_content('Q1')
      # Rating buttons exist in the DOM (hidden until JS flip; tested with visible: :all)
      expect(page).to have_button('Again', visible: :all)
      expect(page).to have_button('Hard',  visible: :all)
      expect(page).to have_button('Good',  visible: :all)
      expect(page).to have_button('Easy',  visible: :all)
    end

    it 'advances to the next card after rating Good' do
      start_session
      rate('Good')

      expect(page).to have_content('Q2')
    end

    it 'completes the session after rating all cards' do
      start_session
      rate('Good')
      rate('Good')
      rate('Good')

      expect(page).to have_content('Session Complete')
      expect(page).to have_content('3')
    end

    it 'shows a summary with rating breakdown after completion' do
      start_session
      rate('Good')
      rate('Easy')
      rate('Hard')

      expect(page).to have_content('Session Complete')
      expect(page).to have_content('Good')
      expect(page).to have_content('Easy')
      expect(page).to have_content('Hard')
    end

    it 're-queues a card rated Again and shows it later' do
      start_session
      rate('Again') # card1 re-queued

      expect(page).to have_content('Q2')
      rate('Good')

      expect(page).to have_content('Q3')
      rate('Good')

      # card1 re-appears due to Again re-queue
      expect(page).to have_content('Q1')
      rate('Good')

      expect(page).to have_content('Session Complete')
    end

    it 'caps Again re-queue at 3 times and then ends session' do
      single_card_deck = create(:deck, user: user)
      create(:card, deck: single_card_deck, front: 'Tough Q', back: 'Tough A')

      visit deck_path(single_card_deck)
      click_button 'Start Session'

      # Rate "Again" up to the cap (MAX_AGAIN_REQUEUES = 3), then once more
      4.times { rate('Again') }

      expect(page).to have_content('Session Complete')
    end

    it 'shows progress indicator for cards remaining' do
      start_session

      expect(page).to have_content('Card 1 of 3')
      rate('Good')

      expect(page).to have_content('Card 2 of 3')
    end

    it 'has a Back to Deck link in the summary' do
      start_session
      rate('Good')
      rate('Good')
      rate('Good')

      expect(page).to have_link('Back to Deck')
    end

    # Regression: rating breakdown badges were all showing 0 because
    # transform_keys used Hash#key(label) which searches by value (always nil
    # when values are integers) — fixed by removing the transform entirely.
    it 'shows correct non-zero counts in the rating breakdown badges' do
      start_session
      rate('Good')  # card1
      rate('Easy')  # card2
      rate('Hard')  # card3

      expect(page).to have_content('Session Complete')

      # Each rating section is a .text-center div containing the badge count
      # and the label text directly below it.
      within(all('.text-center').find { |n| n.text.include?('Good') }) do
        expect(page).to have_content('1')
      end
      within(all('.text-center').find { |n| n.text.include?('Easy') }) do
        expect(page).to have_content('1')
      end
      within(all('.text-center').find { |n| n.text.include?('Hard') }) do
        expect(page).to have_content('1')
      end
      within(all('.text-center').find { |n| n.text.include?('Again') }) do
        expect(page).to have_content('0')
      end
    end
  end
end
