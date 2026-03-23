# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Deck, type: :model do
  describe 'validations' do
    subject { build(:deck) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires a name' do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it 'is invalid with a blank name' do
      subject.name = '  '
      expect(subject).not_to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:cards).dependent(:destroy) }
  end

  describe 'scoping' do
    it 'only returns decks belonging to the given user' do
      user1 = create(:user)
      user2 = create(:user)
      deck1 = create(:deck, user: user1)
      _deck2 = create(:deck, user: user2)

      expect(described_class.where(user: user1)).to contain_exactly(deck1)
    end
  end
end
