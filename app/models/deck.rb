# frozen_string_literal: true

# T023 — Deck model
class Deck < ApplicationRecord
  belongs_to :user
  has_many :cards, dependent: :destroy
  has_many :study_sessions, dependent: :destroy

  validates :name, presence: true
end
