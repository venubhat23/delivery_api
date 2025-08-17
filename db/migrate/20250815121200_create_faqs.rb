class CreateFaqs < ActiveRecord::Migration[7.1]
  def change
    create_table :faqs do |t|
      t.string :category
      t.text :question, null: false
      t.text :answer, null: false
      t.string :locale, default: 'en', null: false
      t.boolean :is_active, default: true, null: false
      t.integer :sort_order, default: 0, null: false
      t.timestamps
    end

    add_index :faqs, :locale
    add_index :faqs, :is_active
    add_index :faqs, [:category, :locale]
    add_index :faqs, :sort_order
  end
end