class AddProductQuantityUnitToDeliveryAssignments < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:products)

      add_reference :delivery_assignments, :product, foreign_key: true
      add_column :delivery_assignments, :quantity, :float
      add_column :delivery_assignments, :unit, :string
    end
  end
end
