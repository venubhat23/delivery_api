class AddStateToCustomers < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :state, :string
  end
end
