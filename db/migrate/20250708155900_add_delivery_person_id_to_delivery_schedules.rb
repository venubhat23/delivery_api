class AddDeliveryPersonIdToDeliverySchedules < ActiveRecord::Migration[7.1]
  def change
    add_column :delivery_schedules, :delivery_person_id, :integer
    add_index :delivery_schedules, :delivery_person_id
  end
end
