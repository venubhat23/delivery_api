class CustomerAddress < ApplicationRecord
  belongs_to :customer

  validates :customer_id, presence: true
  validates :address_type, presence: true, inclusion: { in: %w[home office other] }
  validates :street_address, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :pincode, presence: true, format: { with: /\A\d{6}\z/, message: "should be 6 digits" }

  scope :default_address, -> { where(is_default: true) }

  before_save :ensure_single_default

  def full_address
    parts = []
    parts << street_address if street_address.present?
    parts << landmark if landmark.present?
    parts << city if city.present?
    parts << state if state.present?
    parts << pincode if pincode.present?
    parts.join(', ')
  end

  def display_address_type
    address_type&.titleize || 'Address'
  end

  private

  def ensure_single_default
    if is_default? && is_default_changed?
      # Set all other addresses for this customer to non-default
      CustomerAddress.where(customer: customer, is_default: true)
                    .where.not(id: id)
                    .update_all(is_default: false)
    end
  end
end