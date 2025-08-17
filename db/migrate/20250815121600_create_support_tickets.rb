class CreateSupportTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :support_tickets do |t|
      t.bigint :customer_id
      t.string :subject
      t.text :message, null: false
      t.string :channel, default: 'app', null: false
      t.string :status, default: 'open', null: false
      t.string :external_id
      t.timestamps
    end

    add_index :support_tickets, :customer_id
    add_index :support_tickets, :status
    add_foreign_key :support_tickets, :customers
  end
end