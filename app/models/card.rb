# frozen_string_literal: true

# T024 — Card model
class Card < ApplicationRecord
  belongs_to :deck
  has_one :card_schedule, dependent: :destroy
  has_many :session_ratings, dependent: :destroy

  validates :front, presence: true
  validates :back,  presence: true
end
