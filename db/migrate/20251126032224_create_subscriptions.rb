class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :plan_type
      t.decimal :amount, precision: 10, scale: 2
      t.string :status
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end
  end
end
