class CreateTurns < ActiveRecord::Migration[5.0]
  def change
    create_table :turns do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :game, foreign_key: true
      t.integer :score
      t.integer :sequence_nbr
      t.boolean :bingo
      t.string :state
      t.text :start_letters
      t.text :end_letters
      t.datetime :started
      t.datetime :ended

      t.timestamps
    end
  end
end
