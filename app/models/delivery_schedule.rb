class DeliverySchedule < ApplicationRecord
  belongs_to :customer
  belongs_to :user
  belongs_to :product, optional: true
  has_many :delivery_assignments, dependent: :destroy
  
  validates :frequency, presence: true, inclusion: { in: %w(daily weekly monthly) }
  validates :start_date, presence: true
  validates :default_quantity, presence: true, numericality: { greater_than: 0 }
  validates :default_unit, presence: true
  
  # Ensure end_date is after start_date if present
  validate :end_date_after_start_date, if: -> { end_date.present? }
  
  scope :active, -> { where(status: 'active') }
  scope :by_customer, ->(customer_id) { where(customer_id: customer_id) }
  scope :by_delivery_person, ->(user_id) { where(user_id: user_id) }
  
  def as_json(options = {})
    super(options.merge(
      except: [:created_at, :updated_at],
      include: {
        customer: { only: [:id, :name, :address] },
        user: { only: [:id, :name, :phone] },
        product: { only: [:id, :name, :unit_type, :price] }
      }
    ))
  end
  
  def duration_in_days
    return nil unless end_date
    (end_date - start_date).to_i + 1
  end
  
  def total_assignments_count
    return nil unless end_date
    case frequency
    when 'daily'
      duration_in_days
    when 'weekly'
      (duration_in_days / 7.0).ceil
    when 'monthly'
      (duration_in_days / 30.0).ceil
    end
  end
  
  private
  
  def end_date_after_start_date
    if end_date <= start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
