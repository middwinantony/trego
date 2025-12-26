class AddTipFieldsToPayments < ActiveRecord::Migration[7.1]
  def change
    add_column :payments, :tip_amount, :decimal, precision: 10, scale: 2, default: 0.0, null: false
    add_column :payments, :base_fare, :decimal, precision: 10, scale: 2
  end
end
