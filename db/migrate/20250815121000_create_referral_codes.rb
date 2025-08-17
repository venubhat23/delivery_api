class CreateReferralCodes < ActiveRecord::Migration[7.1]
  def change
    create_table :referral_codes do |t|
      t.bigint :customer_id, null: false
      t.string :code, null: false
      t.integer :total_credits, default: 0, null: false
      t.integer :total_referrals, default: 0, null: false
      t.string :share_url_slug
      t.timestamps
    end

    add_index :referral_codes, :customer_id, unique: true
    add_index :referral_codes, :code, unique: true
    add_foreign_key :referral_codes, :customers
  end
end