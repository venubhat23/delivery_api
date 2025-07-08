class CreateAnalytics < ActiveRecord::Migration[7.0]
  def change
    create_table :analytics do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :total_likes, default: 0
      t.integer :total_comments, default: 0
      t.integer :total_shares, default: 0
      t.integer :total_saves, default: 0
      t.integer :total_clicks, default: 0
      t.integer :total_reach, default: 0
      t.integer :profile_visits, default: 0
      t.integer :followers_count, default: 0
      t.integer :following_count, default: 0
      t.integer :media_count, default: 0
      t.integer :reach_potential, default: 0
      t.integer :earned_media, default: 0

      t.timestamps
    end

    add_index :analytics, :user_id
  end
end