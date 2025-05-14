class Customer < ApplicationRecord
  belongs_to :user
  has_many :deliveries
  has_many :delivery_schedules, dependent: :destroy
  has_many :delivery_assignments, dependent: :restrict_with_error
  
  # Delegate user attributes for convenience
  delegate :name, to: :user, prefix: true, allow_nil: true
  delegate :email, :phone, to: :user, allow_nil: true

  validates :name, presence: true
  validates :address, presence: true
  validates :latitude, presence: true, numericality: true
  validates :longitude, presence: true, numericality: true
  
  reverse_geocoded_by :latitude, :longitude
  
  def as_json(options = {})
    super(options.merge(
      except: [:created_at, :updated_at],
      methods: [:user_name],
      include: {
        user: { only: [:id, :email, :phone] }
      }
    ))
  end
  
  def user_name
    user.name
  end
end
