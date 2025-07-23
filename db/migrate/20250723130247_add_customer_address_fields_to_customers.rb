class AddCustomerAddressFieldsToCustomers < ActiveRecord::Migration[7.1]
  def change
    # Only add fields that don't already exist in customers table
    # Existing fields we can use: address, latitude, longitude, phone_number, address_landmark
    
    # Add only the missing required fields
    add_column :customers, :address_line, :string unless column_exists?(:customers, :address_line)
    add_column :customers, :city, :string unless column_exists?(:customers, :city)
    add_column :customers, :state, :string unless column_exists?(:customers, :state)
    add_column :customers, :postal_code, :string unless column_exists?(:customers, :postal_code)
    add_column :customers, :country, :string unless column_exists?(:customers, :country)
    add_column :customers, :full_address, :text unless column_exists?(:customers, :full_address)
    
    # Update existing latitude and longitude to have proper precision if needed
    change_column :customers, :latitude, :decimal, precision: 10, scale: 6
    change_column :customers, :longitude, :decimal, precision: 10, scale: 6
    
    # Note: We'll use existing fields:
    # - address (can be used as fallback for address_line)
    # - phone_number (already exists)
    # - address_landmark (can be used as landmark)
    # - latitude, longitude (already exist, just updating precision)
  end
end