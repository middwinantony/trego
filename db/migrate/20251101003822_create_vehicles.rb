class CreateVehicles < ActiveRecord::Migration[7.1]
  def change
    create_table :vehicles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :make
      t.string :model
      t.string :plate
      t.string :color

      t.timestamps
    end
  end
end
