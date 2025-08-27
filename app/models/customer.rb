class Customer < ApplicationRecord
  # Associations
  has_secure_password
  
  # Virtual attribute for password confirmation
  attr_accessor :password_confirmation
  
  # Callbacks
  before_save :normalize_member_id
  
  belongs_to :user
  belongs_to :delivery_person, class_name: 'User', optional: true
  has_many :deliveries, dependent: :destroy
  has_many :delivery_assignments, dependent: :destroy
  has_many :delivery_schedules, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :faqs, dependent: :destroy
  has_many :support_tickets, dependent: :destroy
  has_many :customer_addresses, dependent: :destroy
  has_one :customer_preference, dependent: :destroy
  has_one :referral_code, dependent: :destroy
  has_many :refresh_tokens, dependent: :destroy
  has_many :user_vacations, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :phone_number, presence: true
  validates :address, presence: true, length: { minimum: 5, maximum: 255 }
  validates :user_id, presence: true
  validates :member_id, uniqueness: { allow_blank: true }, allow_blank: true
  validates :latitude, numericality: { 
    greater_than_or_equal_to: -90, 
    less_than_or_equal_to: 90,
    allow_blank: true,
    message: "must be between -90 and 90 degrees"
  }
  validates :longitude, numericality: { 
    greater_than_or_equal_to: -180, 
    less_than_or_equal_to: 180,
    allow_blank: true,
    message: "must be between -180 and 180 degrees"
  }

  # Custom validation for delivery person assignment
  validate :delivery_person_capacity_check, if: :delivery_person_id_changed?

  # Custom validation to ensure both lat and lng are provided together
  validate :coordinates_presence
  
  # Scopes
  scope :assigned, -> { where.not(delivery_person_id: nil) }
  scope :unassigned, -> { where(delivery_person_id: nil) }
  scope :with_coordinates, -> { where.not(latitude: nil, longitude: nil) }
  scope :without_coordinates, -> { where(latitude: nil, longitude: nil) }
  scope :search, ->(term) {
    where(
      "name ILIKE :q OR address ILIKE :q OR phone_number ILIKE :q OR alt_phone_number ILIKE :q OR email ILIKE :q OR member_id ILIKE :q",
      q: "%#{term}%"
    )
  }
  scope :by_user, ->(user) { where(user: user) }
  scope :by_delivery_person, ->(dp) { where(delivery_person: dp) }
  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where(is_active: true) }
  
  # Address validations (only when address fields are being updated via API)
  validates :city, presence: true, if: :address_api_context?
  validates :state, presence: true, if: :address_api_context?
  validates :postal_code, presence: true, if: :address_api_context?
  validates :country, presence: true, if: :address_api_context?
  
  reverse_geocoded_by :latitude, :longitude
  
  # Virtual attribute to control when address validations should apply
  attr_accessor :address_api_context
  
  # CSV template for bulk import
  def self.csv_template
    "name,phone_number,address,email,gst_number,pan_number,member_id,latitude,longitude\n" +
    "John Doe,9999999999,123 Main St,john@example.com,GST123,PAN123,MEM123,12.9716,77.5946\n" +
    "Jane Smith,8888888888,456 Oak Ave,jane@example.com,,,,,\n"
  end
  
  # Import customers from CSV data
  def self.import_from_csv(csv_data, current_user)
    require 'csv'
    
    result = {
      success: false,
      imported_count: 0,
      errors: [],
      skipped_rows: [],
      message: ''
    }
    
    begin
      # Parse CSV data
      csv = CSV.parse(csv_data.strip, headers: true, header_converters: :symbol)
      
      if csv.empty?
        result[:message] = "CSV file is empty"
        return result
      end
      
      # Validate required headers
      required_headers = [:name, :phone_number, :address]
      missing_headers = required_headers - csv.headers.compact.map(&:to_sym)
      
      if missing_headers.any?
        result[:message] = "Missing required columns: #{missing_headers.join(', ')}"
        return result
      end
      
      imported_count = 0
      csv.each_with_index do |row, index|
        row_number = index + 2 # +2 because index starts at 0 and we have headers
        
        # Skip empty rows
        if row[:name].blank? && row[:phone_number].blank? && row[:address].blank?
          result[:skipped_rows] << "Row #{row_number}: Empty row"
          next
        end
        
        # Validate required fields
        if row[:name].blank?
          result[:errors] << "Row #{row_number}: Name is required"
          next
        end
        
        if row[:phone_number].blank?
          result[:errors] << "Row #{row_number}: Phone number is required"
          next
        end
        
        if row[:address].blank?
          result[:errors] << "Row #{row_number}: Address is required"
          next
        end
        
        # Check if customer already exists
        existing_customer = Customer.find_by(
          name: row[:name].to_s.strip,
          phone_number: row[:phone_number].to_s.strip
        )
        
        if existing_customer
          result[:errors] << "Row #{row_number}: Customer '#{row[:name]}' with phone '#{row[:phone_number]}' already exists"
          next
        end
        
        # Create customer
        customer = Customer.new(
          name: row[:name].to_s.strip,
          phone_number: row[:phone_number].to_s.strip,
          address: row[:address].to_s.strip,
          email: row[:email].to_s.strip.presence,
          gst_number: row[:gst_number].to_s.strip.presence,
          pan_number: row[:pan_number].to_s.strip.presence,
          member_id: row[:member_id].to_s.strip.presence,
          user: current_user
        )
        
        # Set default password as specified by user
        customer.password = "customer@123"
        customer.password_confirmation = "customer@123"
        
        # Handle coordinates if provided
        if row[:latitude].present? && row[:longitude].present?
          customer.latitude = row[:latitude].to_f
          customer.longitude = row[:longitude].to_f
        end
        
        if customer.save
          imported_count += 1
        else
          error_messages = customer.errors.full_messages.join(', ')
          result[:errors] << "Row #{row_number}: #{error_messages}"
        end
      end
      
      result[:success] = true
      result[:imported_count] = imported_count
      result[:message] = "Import completed successfully"
      
    rescue CSV::MalformedCSVError => e
      result[:message] = "Invalid CSV format: #{e.message}"
    rescue => e
      result[:message] = "Error processing CSV: #{e.message}"
    end
    
    result
  end
  
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

  def has_active_vacation_on?(date)
    user_vacations.active.overlapping_with(date, date).exists?
  end

  def active_vacation_on(date)
    user_vacations.active.overlapping_with(date, date).first
  end
  
  # Instance methods
  def assigned?
    delivery_person.present?
  end

  def has_coordinates?
    latitude.present? && longitude.present?
  end

  def coordinates
    return nil unless has_coordinates?
    [latitude.to_f, longitude.to_f]
  end

  def coordinates_string
    return "No coordinates" unless has_coordinates?
    "#{latitude.to_f.round(6)}, #{longitude.to_f.round(6)}"
  end

  def google_maps_url
    return nil unless has_coordinates?
    "https://www.google.com/maps/search/?api=1&query=#{latitude},#{longitude}"
  end

  def initials
    name.split.map(&:first).join.upcase[0, 2]
  end

  def full_address_with_coordinates
    address_parts = [address]
    address_parts << coordinates_string if has_coordinates?
    address_parts.join(" | ")
  end

  def customer_since
    created_at.strftime("%B %Y")
  end

  def formatted_id
    "##{id.to_s.rjust(6, '0')}"
  end

  def delivery_person_name
    delivery_person&.name || "Not Assigned"
  end

  # Delivery related methods
  def total_deliveries
    deliveries.count
  end

  def pending_deliveries
    deliveries.where(status: 'pending').count
  end

  def completed_deliveries
    deliveries.where(status: 'completed').count
  end

  def last_delivery_date
    deliveries.order(:delivery_date).last&.delivery_date
  end

  def delivery_assignments_count
    delivery_assignments.count
  end

  def active_schedules
    delivery_schedules.where(status: 'active')
  end

  def has_active_schedule?
    active_schedules.exists?
  end

  # Invoice related methods
  def total_invoices
    invoices.count
  end

  def total_invoice_amount
    invoices.sum(:total_amount) || 0
  end

  def pending_invoice_amount
    invoices.where(status: 'pending').sum(:total_amount) || 0
  end
  
  # Distance calculation
  def distance_from(lat, lng)
    return nil unless has_coordinates?
    
    # Using Haversine formula for distance calculation
    rad_per_deg = Math::PI / 180  # PI / 180
    rkm = 6371                    # Earth radius in kilometers
    rm = rkm * 1000               # Radius in meters

    dlat_rad = (lat - latitude.to_f) * rad_per_deg
    dlon_rad = (lng - longitude.to_f) * rad_per_deg

    lat1_rad, lat2_rad = latitude.to_f * rad_per_deg, lat * rad_per_deg

    a = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    rm * c # Distance in meters
  end
  
  # Helper methods for new features
  def default_address
    customer_addresses.default_address.first || customer_addresses.first
  end

  def preferences
    customer_preference || build_customer_preference
  end

  def preferred_language
    preferences.language || 'en'
  end

  def delivery_time_window
    preferences.delivery_time_window
  end

  def notification_preferences
    preferences.notification_settings
  end

  def referral
    referral_code || create_referral_code
  end
  
  # Class methods
  def self.with_pending_deliveries
    joins(:deliveries).where(deliveries: { status: 'pending' }).distinct
  end

  def self.without_deliveries
    left_joins(:deliveries).where(deliveries: { id: nil })
  end

  def self.active_customers
    joins(:deliveries).where('deliveries.created_at > ?', 3.months.ago).distinct
  end

  def self.available_for_assignment
    unassigned.includes(:user)
  end
  
  private

  def normalize_member_id
    self.member_id = member_id.presence&.strip
  end

  def delivery_person_capacity_check
    return if delivery_person_id.blank?
    # Assume a capacity check exists elsewhere; this is a placeholder
    true
  end

  def coordinates_presence
    if latitude.present? ^ longitude.present?
      errors.add(:base, "Both latitude and longitude must be provided together")
    end
  end
  
  def address_api_context?
    @address_api_context == true
  end
  
  def address_line_or_address_present
    if get_address_line.blank?
      errors.add(:address_line, "can't be blank")
    end
  end
end
