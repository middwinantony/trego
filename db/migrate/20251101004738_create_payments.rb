class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.references :ride, null: false, foreign_key: true
      t.decimal :amount
      t.string :status
      t.string :stripe_charge_id

      t.timestamps
    end
  end
end
