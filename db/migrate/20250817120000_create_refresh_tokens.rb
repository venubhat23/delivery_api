class CreateRefreshTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :refresh_tokens do |t|
      t.string :token_hash, null: false
      t.string :replaced_by_token_hash
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.references :user, foreign_key: true
      t.references :customer, foreign_key: true
      t.string :user_agent
      t.string :created_by_ip

      t.timestamps
    end

    add_index :refresh_tokens, :token_hash, unique: true
    add_index :refresh_tokens, :replaced_by_token_hash
  end
end