class AddMissingFieldsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_reference :products, :category, null: true, foreign_key: true
    add_column :products, :image_url, :string
    add_column :products, :sku, :string
    add_column :products, :stock_alert_threshold, :integer
    add_column :products, :is_subscription_eligible, :boolean, default: false
    add_column :products, :is_active, :boolean, default: true
    
    add_index :products, :sku, unique: true
    add_index :products, :is_active
    add_index :products, :is_subscription_eligible
  end
end