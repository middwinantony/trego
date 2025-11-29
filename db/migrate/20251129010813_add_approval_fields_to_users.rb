class AddApprovalFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :approved, :boolean, default: false, null: false
    add_column :users, :kyc_status, :string, default: 'pending'
  end
end
