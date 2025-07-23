class Customer < ApplicationRecord
  belongs_to :user
  belongs_to :delivery_person, class_name: 'User', optional: true
  has_many :deliveries, dependent: :destroy
  has_many :delivery_schedules, dependent: :destroy
  has_many :delivery_assignments, dependent: :restrict_with_error
  has_many :invoices, dependent: :destroy
  has_many :customer_addresses, dependent: :destroy
  
  # Delegate user attributes for convenience
  delegate :name, to: :user, prefix: true, allow_nil: true
  delegate :email, :phone, to: :user, allow_nil: true

  validates :name, presence: true
  
  reverse_geocoded_by :latitude, :longitude
  
  scope :active, -> { where(is_active: true) }
  scope :by_delivery_person, ->(delivery_person_id) { where(delivery_person_id: delivery_person_id) }
  
  def as_json(options = {})
    super(options.merge(
      except: [:created_at, :updated_at],
      methods: [:user_name],
      include: {
        user: { only: [:id, :email, :phone] },
        delivery_person: { only: [:id, :name, :phone] }
      }
    ))
  end
  
  def user_name
    user.name
  end
  
  def full_address
    [address, address_landmark].compact.join(', ')
  end
  
  def primary_phone
    phone_number.presence || user&.phone
  end
  
  def primary_email
    email.presence || user&.email
  end
end
