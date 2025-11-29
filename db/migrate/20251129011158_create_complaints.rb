class CreateComplaints < ActiveRecord::Migration[7.1]
  def change
    create_table :complaints do |t|
      t.references :user, null: false, foreign_key: true
      t.references :ride, null: true, foreign_key: true
      t.string :subject, null: false
      t.text :description, null: false
      t.string :status, default: 'open', null: false

      t.timestamps
    end
  end
end
