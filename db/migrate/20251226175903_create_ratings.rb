class CreateRatings < ActiveRecord::Migration[7.1]
  def change
    create_table :ratings do |t|
      t.references :ride, null: false, foreign_key: true, index: { unique: true }
      t.references :rater, null: false, foreign_key: { to_table: :users }
      t.references :ratee, null: false, foreign_key: { to_table: :users }
      t.integer :score, null: false
      t.text :comment

      t.timestamps
    end

    add_index :ratings, [:ratee_id, :created_at]
  end
end
