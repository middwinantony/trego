class AddRiderFlowFieldsToRides < ActiveRecord::Migration[7.1]
  def change
    add_column :rides, :ride_type, :string, default: 'economy', null: false
    add_column :rides, :requested_at, :datetime
    add_column :rides, :matched_at, :datetime
    add_column :rides, :started_at, :datetime
    add_column :rides, :completed_at, :datetime
    add_column :rides, :estimated_duration, :integer
    add_column :rides, :estimated_arrival, :datetime

    add_index :rides, :ride_type
  end
end
