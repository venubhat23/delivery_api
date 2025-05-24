class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:products)

      create_table :customers do |t|
        t.string :name
        t.string :address
        t.decimal :latitude
        t.decimal :longitude
        t.references :user, null: false, foreign_key: true

        t.timestamps
      end
    end
  end
end
