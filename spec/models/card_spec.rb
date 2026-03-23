# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Card, type: :model do
  describe 'validations' do
    subject { build(:card) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires a front' do
      subject.front = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:front]).to include("can't be blank")
    end

    it 'requires a back' do
      subject.back = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:back]).to include("can't be blank")
    end

    it 'is invalid with blank front' do
      subject.front = '  '
      expect(subject).not_to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:deck) }
  end
end
