class AddWordsToTurns < ActiveRecord::Migration[5.0]
  def change
    add_column :turns, :words, :string
  end
end
