class CreateKycDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :kyc_documents do |t|
      t.references :user, null: false, foreign_key: true
      t.string :document_type, null: false
      t.string :status, default: 'pending', null: false

      t.timestamps
    end
  end
end
