class Customer < ApplicationRecord
  belongs_to :user
  belongs_to :delivery_person, class_name: 'User', optional: true
  has_many :deliveries, dependent: :destroy
  has_many :delivery_schedules, dependent: :destroy
  has_many :delivery_assignments, dependent: :restrict_with_error
  has_many :invoices, dependent: :destroy
  
  # Delegate user attributes for convenience
  delegate :name, to: :user, prefix: true, allow_nil: true
  delegate :email, :phone, to: :user, allow_nil: true

  validates :name, presence: true
  
  # Address validations (only when address fields are being updated via API)
  validates :address_line, presence: true, if: :address_api_context?
  validates :city, presence: true, if: :address_api_context?
  validates :state, presence: true, if: :address_api_context?
  validates :postal_code, presence: true, if: :address_api_context?
  validates :country, presence: true, if: :address_api_context?
  validates :phone_number, presence: true, if: :address_api_context?
  validates :full_address, presence: true, if: :address_api_context?
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, if: :address_api_context?
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, if: :address_api_context?
  
  reverse_geocoded_by :latitude, :longitude
  
  scope :active, -> { where(is_active: true) }
  scope :by_delivery_person, ->(delivery_person_id) { where(delivery_person_id: delivery_person_id) }
  
  # Virtual attribute to control when address validations should apply
  attr_accessor :address_api_context
  
  def as_json(options = {})
    if options[:address_api_format]
      # Format for address API responses
      {
        id: id,
        customer_id: id, # For API compatibility
        address_line: address_line,
        city: city,
        state: state,
        postal_code: postal_code,
        country: country,
        phone_number: phone_number,
        landmark: landmark || address_landmark,
        full_address: full_address,
        longitude: longitude,
        latitude: latitude
      }
    else
      # Default format
      super(options.merge(
        except: [:created_at, :updated_at],
        methods: [:user_name],
        include: {
          user: { only: [:id, :email, :phone] },
          delivery_person: { only: [:id, :name, :phone] }
        }
      ))
    end
  end
  
  def user_name
    user.name
  end
  
  def full_address
    return super if super.present?
    
    # Generate full_address from components if not set
    parts = []
    parts << address_line if address_line.present?
    parts << (landmark.presence || address_landmark) if landmark.present? || address_landmark.present?
    parts << city if city.present?
    parts << state if state.present?
    parts << postal_code if postal_code.present?
    parts << country if country.present?
    parts.join(', ')
  end
  
  def formatted_address
    full_address
  end
  
  def primary_phone
    phone_number.presence || user&.phone
  end
  
  def primary_email
    email.presence || user&.email
  end
  
  private
  
  def address_api_context?
    @address_api_context == true
  end
end
