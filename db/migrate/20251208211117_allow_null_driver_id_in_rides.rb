class AllowNullDriverIdInRides < ActiveRecord::Migration[7.1]
  def change
    change_column_null :rides, :driver_id, true
  end
end
