class AddCodToDeliverySchedules < ActiveRecord::Migration[7.1]
  def change
    add_column :delivery_schedules, :cod, :boolean, default: false
  end
end
