# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is invalid without a username' do
      subject.username = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:username]).to include("can't be blank")
    end

    it 'is invalid with a blank username' do
      subject.username = '  '
      expect(subject).not_to be_valid
    end

    it 'is invalid with a duplicate username' do
      create(:user, username: 'taken')
      subject.username = 'taken'
      expect(subject).not_to be_valid
      expect(subject.errors[:username]).to include('has already been taken')
    end

    it 'is invalid without a password' do
      subject.password = nil
      subject.password_confirmation = nil
      expect(subject).not_to be_valid
    end

    it 'is invalid when password is too short (< 8 chars)' do
      subject.password = 'short'
      subject.password_confirmation = 'short'
      expect(subject).not_to be_valid
    end

    it 'is valid with a password of exactly 8 characters' do
      subject.password = 'exactly8'
      subject.password_confirmation = 'exactly8'
      expect(subject).to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:decks).dependent(:destroy) }
  end

  describe 'authentication' do
    let(:user) { create(:user, password: 'correct_pass', password_confirmation: 'correct_pass') }

    it 'authenticates with the correct password' do
      expect(user.authenticate('correct_pass')).to eq(user)
    end

    it 'returns false for incorrect password' do
      expect(user.authenticate('wrong_pass')).to be_falsey
    end
  end
end
