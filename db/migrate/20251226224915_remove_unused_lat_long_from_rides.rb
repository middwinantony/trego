class RemoveUnusedLatLongFromRides < ActiveRecord::Migration[7.1]
  def change
    remove_column :rides, :latitude, :float
    remove_column :rides, :longitude, :float
  end
end
