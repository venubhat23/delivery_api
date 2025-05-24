class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:products)

      create_table :users do |t|
        t.string :name
        t.string :email
        t.string :phone
        t.string :password_digest
        t.string :role

        t.timestamps
      end
    end
  end
end
