class AddIndexOnDeliveryAssignments < ActiveRecord::Migration[7.1]
  def change
    add_index :delivery_assignments, [:customer_id, :scheduled_date]
  end
end