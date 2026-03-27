# frozen_string_literal: true

require 'rails_helper'

# T074 — Regression spec: flash message close button markup
#
# JS behaviour (Bootstrap Alert dismiss) cannot be exercised with the
# rack_test driver.  These tests verify:
#   1. Flash messages are rendered with the correct Bootstrap classes so
#      that Bootstrap JS can attach its document-level dismiss listener.
#   2. Every flash alert contains a btn-close button with the
#      data-bs-dismiss="alert" attribute that Bootstrap JS targets.
#
# Full JS dismissal (click → element removed from DOM) is covered by
# manual QA or a Selenium/Cuprite suite.
RSpec.describe 'Flash messages', type: :system do
  before { driven_by(:rack_test) }

  let(:user) { create(:user) }

  def login_as(usr)
    visit new_session_path
    fill_in 'Username', with: usr.username
    fill_in 'Password', with: 'password123'
    click_button 'Log in'
  end

  describe 'close button markup' do
    context 'when a notice flash is present' do
      it 'renders an alert-dismissible div with a data-bs-dismiss btn-close button' do
        login_as(user) # triggers a "Welcome" notice flash

        expect(page).to have_css('.alert.alert-dismissible')
        expect(page).to have_css('[data-bs-dismiss="alert"]')
        expect(page).to have_button('Close', visible: :all)
      end
    end

    context 'when an alert flash is present' do
      it 'renders an alert-danger alert-dismissible div' do
        # Trigger an alert by attempting login with wrong password
        visit new_session_path
        fill_in 'Username', with: user.username
        fill_in 'Password', with: 'wrongpassword'
        click_button 'Log in'

        expect(page).to have_css('.alert.alert-danger.alert-dismissible')
        expect(page).to have_css('[data-bs-dismiss="alert"]')
      end
    end

    context 'when there is no flash' do
      it 'renders no alert elements' do
        login_as(user)
        visit decks_path # navigating away clears the flash

        expect(page).to have_no_css('.flash-messages .alert')
      end
    end
  end

  describe 'flash-auto-dismiss class' do
    it 'marks every flash alert for JS auto-dismissal after 4 s' do
      login_as(user)

      expect(page).to have_css('.alert.flash-auto-dismiss')
    end
  end
end
