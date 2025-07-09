class AddDeliveryPersonIdToDeliveryAssignments < ActiveRecord::Migration[7.1]
  def change
    add_column :delivery_assignments, :delivery_person_id, :integer
  end
end
