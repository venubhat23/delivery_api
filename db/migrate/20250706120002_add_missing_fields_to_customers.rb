class AddMissingFieldsToCustomers < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :preferred_language, :string
    add_column :customers, :delivery_time_preference, :string
    add_column :customers, :notification_method, :string
    add_column :customers, :alt_phone_number, :string
    add_column :customers, :profile_image_url, :string
    add_column :customers, :address_landmark, :string
    add_column :customers, :address_type, :string
    add_column :customers, :is_active, :boolean, default: true
    
    add_index :customers, :member_id, unique: true
    add_index :customers, :is_active
  end
end