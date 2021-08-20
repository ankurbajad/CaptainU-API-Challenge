class CreatePlayers < ActiveRecord::Migration[6.0]
  def change
    create_table :players do |t|
      t.string :first_name
      t.string :last_name
      t.integer :height
      t.integer :weight
      t.string :birthday
      t.integer :graduation_year
      t.string :position
      t.boolean :recruit

      t.timestamps
    end
  end
end
