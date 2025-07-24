class CreateAdminSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_settings do |t|
      t.string :business_name, null: false
      t.text :address
      t.string :mobile, null: false
      t.string :email, null: false
      t.string :gstin
      t.string :pan_number
      t.string :account_holder_name, null: false
      t.string :bank_name, null: false
      t.string :account_number, null: false
      t.string :ifsc_code, null: false
      t.string :upi_id
      t.text :terms_and_conditions
      t.string :qr_code_path

      t.timestamps
    end

    # Add indexes for commonly queried fields
    add_index :admin_settings, :email, unique: true
    add_index :admin_settings, :mobile
  end
end