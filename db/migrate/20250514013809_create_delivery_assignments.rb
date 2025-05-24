class CreateDeliveryAssignments < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:products)

      create_table :delivery_assignments do |t|
        t.references :delivery_schedule, null: false, foreign_key: true
        t.references :customer, null: false, foreign_key: true
        t.references :user, null: false, foreign_key: true
        t.date :scheduled_date
        t.string :status
        t.datetime :completed_at

        t.timestamps
      end
    end
  end
end
