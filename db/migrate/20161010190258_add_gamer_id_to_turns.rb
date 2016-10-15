class AddGamerIdToTurns < ActiveRecord::Migration[5.0]
  def change
    add_column :turns, :gamer_id, :integer
  end
end
