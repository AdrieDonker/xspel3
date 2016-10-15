class UpdateUsers < ActiveRecord::Migration[5.0]
  def change
    rename_column :games, :started, :started_at
    add_column :games, :invited_at, :datetime
  end
end
