class CreateAssessments < ActiveRecord::Migration[6.0]
  def change
    create_table :assessments do |t|
      t.string :assessment_type , default: "event"
      t.integer :rating
      t.references :user, null: false, foreign_key: true
      t.references :tournament, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.timestamps
    end
  end
end
