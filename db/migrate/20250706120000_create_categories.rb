class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.string :color, null: false
      t.boolean :is_active, default: true

      t.timestamps
    end

    add_index :categories, :name, unique: true
    add_index :categories, :is_active
  end
end