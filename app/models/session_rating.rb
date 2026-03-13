# frozen_string_literal: true

# T038 — SessionRating model
# Records the learner's recall rating for a single card within a study session.
# rating: again (0), hard (1), good (2), easy (3)
class SessionRating < ApplicationRecord
  belongs_to :study_session
  belongs_to :card

  enum :rating, { again: 0, hard: 1, good: 2, easy: 3 }

  validates :study_session, presence: true
  validates :card,          presence: true
  validates :rating,        presence: true
  validates :reviewed_at,   presence: true
end
