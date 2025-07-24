class AddPincodeAndLandmarkToCustomers < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :pincode, :string
    add_column :customers, :landmark, :string
  end
end
