class CreateDeliveries < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:products)

      create_table :deliveries do |t|
        t.integer :delivery_person_id
        t.references :customer, null: false, foreign_key: true
        t.string :status
        t.date :delivery_date

        t.timestamps
      end
    end
  end
end
