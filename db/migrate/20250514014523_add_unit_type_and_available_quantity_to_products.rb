class AddUnitTypeAndAvailableQuantityToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :unit_type, :string, null: false, default: "unit"
    add_column :products, :available_quantity, :decimal, precision: 10, scale: 2, null: false, default: 0.0
  end
end
