class AddLocationToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :current_latitude, :decimal
    add_column :users, :current_longitude, :decimal
  end
end
