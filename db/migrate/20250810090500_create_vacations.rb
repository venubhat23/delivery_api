class CreateVacations < ActiveRecord::Migration[7.1]
  def change
    create_table :vacations do |t|
      t.references :customer, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.text :notes

      t.timestamps
    end

    add_index :vacations, [:customer_id, :start_date]
    add_index :vacations, [:customer_id, :end_date]
  end
end