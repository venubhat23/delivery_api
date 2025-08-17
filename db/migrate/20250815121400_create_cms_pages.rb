class CreateCmsPages < ActiveRecord::Migration[7.1]
  def change
    create_table :cms_pages do |t|
      t.string :slug, null: false
      t.string :version, default: 'v1.0', null: false
      t.string :title, null: false
      t.text :content, null: false
      t.string :locale, default: 'en', null: false
      t.datetime :published_at
      t.timestamps
    end

    add_index :cms_pages, [:slug, :locale], unique: true
    add_index :cms_pages, :published_at
  end
end