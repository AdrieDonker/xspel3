class AddLaidLettersToTurn < ActiveRecord::Migration[5.0]
  def change
    add_column :turns, :laid_letters, :text
  end
end
