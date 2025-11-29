class AddApprovedToVehicles < ActiveRecord::Migration[7.1]
  def change
    add_column :vehicles, :approved, :boolean, default: false, null: false
  end
end
