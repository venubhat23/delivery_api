class UpdateDeliveryAssignmentsForVacations < ActiveRecord::Migration[7.1]
  def change
    add_column :delivery_assignments, :cancellation_reason, :text
    add_index :delivery_assignments, [:customer_id, :scheduled_date]
  end
end
