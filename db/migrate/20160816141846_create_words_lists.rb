class CreateWordsLists < ActiveRecord::Migration[5.0]
  def change
    create_table :words_lists do |t|
      t.string :name
      t.string :group
      t.string :description
      t.text :words

      t.timestamps
    end
  end
end
