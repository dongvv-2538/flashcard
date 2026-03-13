# frozen_string_literal: true

class CreateStudySessions < ActiveRecord::Migration[7.2]
  def change
    create_table :study_sessions do |t|
      t.references :user,  null: false, foreign_key: true
      t.references :deck,  null: false, foreign_key: true
      t.integer    :session_type,         null: false, default: 0
      t.datetime   :started_at,           null: false
      t.datetime   :ended_at
      t.integer    :cards_reviewed_count, null: false, default: 0

      t.timestamps
    end

    add_index :study_sessions, :session_type
    add_index :study_sessions, :ended_at
  end
end
