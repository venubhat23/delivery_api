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
      t.bigint :created_by, null: true

      t.timestamps
    end

    add_index :user_vacations, [:customer_id, :start_date]
    add_index :user_vacations, [:customer_id, :end_date]
    add_index :user_vacations, :status
    add_index :user_vacations, :created_by
  end
end
