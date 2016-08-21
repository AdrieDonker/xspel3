class CreateSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :settings do |t|
      t.string :name
      t.integer :max_invite_hours
      t.integer :max_play_hours
      t.integer :extra_on_bingo

      t.timestamps
    end
  end
end
