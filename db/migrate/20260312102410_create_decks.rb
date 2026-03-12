# frozen_string_literal: true

class CreateDecks < ActiveRecord::Migration[7.2]
  def change
    create_table :decks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
    add_index :decks, :name
  end
end
