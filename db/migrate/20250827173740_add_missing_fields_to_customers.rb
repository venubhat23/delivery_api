class AddMissingFieldsToCustomers < ActiveRecord::Migration[7.1]
  def change
    # Only add columns that don't already exist in schema.rb
    add_column :customers, :address_line, :string unless column_exists?(:customers, :address_line)
    add_column :customers, :full_address, :string unless column_exists?(:customers, :full_address)
    add_column :customers, :country, :string unless column_exists?(:customers, :country)
    
    # Add indexes for better performance
    add_index :customers, :email, where: "(email IS NOT NULL)"
    add_index :customers, :alt_phone_number, where: "(alt_phone_number IS NOT NULL)"
    add_index :customers, :preferred_language
    add_index :customers, [:latitude, :longitude], where: "(latitude IS NOT NULL AND longitude IS NOT NULL)"
  end
end
