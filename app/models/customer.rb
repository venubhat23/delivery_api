class Customer < ApplicationRecord
  has_secure_password
  
  # Virtual attribute for password confirmation
  attr_accessor :password_confirmation

  belongs_to :user
  belongs_to :delivery_person, class_name: 'User', optional: true
  has_many :deliveries, dependent: :destroy
  has_many :delivery_schedules, dependent: :destroy
  has_many :delivery_assignments, dependent: :restrict_with_error
  has_many :invoices, dependent: :destroy
  has_many :refresh_tokens, dependent: :destroy
  
  # Delegate user attributes for convenience
  delegate :name, to: :user, prefix: true, allow_nil: true
  delegate :email, :phone, to: :user, allow_nil: true

  validates :name, presence: true
  
  # Address validations (only when address fields are being updated via API)
  validates :city, presence: true, if: :address_api_context?
  validates :state, presence: true, if: :address_api_context?
  validates :postal_code, presence: true, if: :address_api_context?
  validates :country, presence: true, if: :address_api_context?
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, if: :address_api_context?
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, if: :address_api_context?
  
  # Custom validation for address_line (use existing address field if address_line is blank)
  
  reverse_geocoded_by :latitude, :longitude
  
  scope :active, -> { where(is_active: true) }
  scope :by_delivery_person, ->(delivery_person_id) { where(delivery_person_id: delivery_person_id) }
  
  # Virtual attribute to control when address validations should apply
  attr_accessor :address_api_context
  
  def as_json(options = {})
    if options[:address_api_format]
      # Format for address API responses - use existing fields where possible
      {
        id: id,
        customer_id: id, # For API compatibility
        city: city,
        state: state,
        postal_code: postal_code,
        phone_number: phone_number,
        landmark: get_landmark,
        full_address: address,
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
  
  # Use full_address if present, otherwise generate from components
  def get_full_address
    return full_address if full_address.present?
    
    # Generate full_address from components
    parts = []
    parts << get_landmark if get_landmark.present?
    parts << city if city.present?
    parts << state if state.present?
    parts << postal_code if postal_code.present?
    parts.join(', ')
  end
  
  # Use address_line if present, otherwise fall back to address
  def get_address_line
    address_line.present? ? address_line : address
  end
  
  # Use address_landmark as landmark (existing field)
  def get_landmark
    address_landmark
  end
  
  def formatted_address
    get_full_address
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
  
  def address_line_or_address_present
    if get_address_line.blank?
      errors.add(:address_line, "can't be blank")
    end
  end
end
