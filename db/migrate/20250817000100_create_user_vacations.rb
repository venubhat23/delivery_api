class CreateUserVacations < ActiveRecord::Migration[7.1]
  def change
    create_table :user_vacations do |t|
      t.references :customer, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :status, null: false, default: 'active'
      t.text :reason
      t.datetime :paused_at
      t.datetime :unpaused_at
      t.datetime :cancelled_at
      t.string :idempotency_key
      t.integer :affected_assignments_skipped, null: false, default: 0
      t.references :created_by, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :user_vacations, [:customer_id, :start_date]
    add_index :user_vacations, [:customer_id, :end_date]
    # Ensure idempotency per customer when header is provided
    add_index :user_vacations, [:customer_id, :idempotency_key], unique: true, where: "idempotency_key IS NOT NULL"
  end
end