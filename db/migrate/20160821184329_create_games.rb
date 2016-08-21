class CreateGames < ActiveRecord::Migration[5.0]
  def change
    create_table :games do |t|
      t.string :name
      t.belongs_to :board, foreign_key: true
      t.belongs_to :letter_set, foreign_key: true
      t.belongs_to :words_list, foreign_key: true
      t.text :words_list_groups
      t.text :extra_words_lists
      t.datetime :started
      t.text :laid_letters
      t.text :stock_letters
      t.string :state

      t.timestamps
    end
  end
end
