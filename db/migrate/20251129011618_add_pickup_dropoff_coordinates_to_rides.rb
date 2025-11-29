class AddPickupDropoffCoordinatesToRides < ActiveRecord::Migration[7.1]
  def change
    add_column :rides, :pickup_latitude, :decimal
    add_column :rides, :pickup_longitude, :decimal
    add_column :rides, :dropoff_latitude, :decimal
    add_column :rides, :dropoff_longitude, :decimal
  end
end
