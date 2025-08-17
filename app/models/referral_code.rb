class ReferralCode < ApplicationRecord
  belongs_to :customer

  validates :code, presence: true, uniqueness: true
  validates :customer_id, presence: true, uniqueness: true

  def share_url(base_url)
    return nil if code.blank?
    base_url.to_s.chomp('/') + "/r/" + code
  end
end