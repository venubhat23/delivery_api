class CreateCustomerAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :customer_addresses do |t|
      t.integer :customer_id, null: false
      t.string :address_line
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country
      t.string :phone_number
      t.string :landmark
      t.text :full_address
      t.decimal :longitude, precision: 10, scale: 6
      t.decimal :latitude, precision: 10, scale: 6

      t.timestamps
    end
    
    add_index :customer_addresses, :customer_id
    add_foreign_key :customer_addresses, :customers
  end
end
