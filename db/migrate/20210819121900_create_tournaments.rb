class CreateTournaments < ActiveRecord::Migration[6.0]
  def change
    create_table :tournaments do |t|
      t.string :name
      t.string :city
      t.string :state
      t.date :start_date

      t.timestamps
    end
  end
end
