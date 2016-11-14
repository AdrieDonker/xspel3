class AddKnowsUsersToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :knows_users, :text
  end
end
