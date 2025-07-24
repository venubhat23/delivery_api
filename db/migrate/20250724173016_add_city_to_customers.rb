class AddCityToCustomers < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :city, :string
  end
end
