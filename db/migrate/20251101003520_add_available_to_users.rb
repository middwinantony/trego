class AddAvailableToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :available, :boolean, default: false, null: false
  end
end
