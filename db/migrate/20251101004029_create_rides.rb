class CreateRides < ActiveRecord::Migration[7.1]
  def change
    create_table :rides do |t|
      t.references :rider, null: false, foreign_key: { to_table: :users }
      t.references :driver, null: false, foreign_key: { to_table: :users }
      t.string :pickup
      t.string :dropoff
      t.string :status
      t.decimal :fare
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
