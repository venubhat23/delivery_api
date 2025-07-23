class CustomerAddress < ApplicationRecord
  belongs_to :customer
  
  validates :customer_id, presence: true
  validates :address_line, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :postal_code, presence: true
  validates :country, presence: true
  validates :phone_number, presence: true
  validates :full_address, presence: true
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  
  # Geocoding functionality (if needed)
  reverse_geocoded_by :latitude, :longitude
  
  def as_json(options = {})
    super(options.merge(
      except: [:created_at, :updated_at]
    ))
  end
  
  def formatted_address
    parts = []
    parts << address_line if address_line.present?
    parts << landmark if landmark.present?
    parts << city if city.present?
    parts << state if state.present?
    parts << postal_code if postal_code.present?
    parts << country if country.present?
    parts.join(', ')
  end
end