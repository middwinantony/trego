class CreateSavedLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :saved_locations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :address, null: false
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.string :location_type, null: false, default: 'custom'

      t.timestamps
    end

    add_index :saved_locations, [:user_id, :location_type]
  end
end
