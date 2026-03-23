# frozen_string_literal: true

# T050 — CardSchedule migration
# Persists the SM-2 spaced repetition state for each card.
class CreateCardSchedules < ActiveRecord::Migration[7.2]
  def change
    create_table :card_schedules do |t|
      t.references :card, null: false, foreign_key: true, index: { unique: true }
      t.date    :next_review_date, null: false
      t.integer :interval_days,    null: false, default: 0
      t.decimal :ease_factor,      null: false, default: 2.5, precision: 4, scale: 2
      t.integer :review_count,     null: false, default: 0
      t.datetime :last_reviewed_at

      t.timestamps
    end

    add_index :card_schedules, :next_review_date
  end
end
