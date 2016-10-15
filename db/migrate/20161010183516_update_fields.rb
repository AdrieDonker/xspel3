class UpdateFields < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :invite_time, :integer
    add_column :games, :play_time, :integer
  end
end
