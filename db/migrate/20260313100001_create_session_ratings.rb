# frozen_string_literal: true

class CreateSessionRatings < ActiveRecord::Migration[7.2]
  def change
    create_table :session_ratings do |t|
      t.references :study_session, null: false, foreign_key: true
      t.references :card,          null: false, foreign_key: true
      t.integer    :rating,        null: false
      t.datetime   :reviewed_at,   null: false

      t.timestamps
    end

    add_index :session_ratings, :rating
    add_index :session_ratings, %i[study_session_id card_id]
  end
end
