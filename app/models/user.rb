# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :decks,         dependent: :destroy
  has_many :study_sessions, dependent: :destroy

  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { maximum: 50 }
  validates :password,
            length: { minimum: 8 },
            allow_nil: true # only required on create via has_secure_password

  normalizes :username, with: ->(u) { u.strip.downcase }
end
