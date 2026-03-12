# frozen_string_literal: true

class CreateCards < ActiveRecord::Migration[7.2]
  def change
    create_table :cards do |t|
      t.references :deck, null: false, foreign_key: true
      t.text :front, null: false
      t.text :back, null: false

      t.timestamps
    end
  end
end
