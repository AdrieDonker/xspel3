class CreateLetterSets < ActiveRecord::Migration[5.0]
  def change
    create_table :letter_sets do |t|
      t.string :name
      t.text :letter_amount_points

      t.timestamps
    end
  end
end
