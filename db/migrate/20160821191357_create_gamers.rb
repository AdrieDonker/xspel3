class CreateGamers < ActiveRecord::Migration[5.0]
  def change
    create_table :gamers do |t|
      t.belongs_to :game, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.integer :sequence_nbr
      t.integer :score
      t.string :state
      t.integer :position

      t.timestamps
    end
  end
end
