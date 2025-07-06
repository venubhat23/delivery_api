class Product < ApplicationRecord
  belongs_to :category, optional: true
  has_many :delivery_items, dependent: :destroy
  has_many :deliveries, through: :delivery_items
  has_many :delivery_assignments, dependent: :destroy
  has_many :delivery_schedules, dependent: :destroy
  has_many :invoice_items, dependent: :destroy

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :unit_type, presence: true
  validates :available_quantity, numericality: { greater_than_or_equal_to: 0 }
  
  scope :active, -> { where(is_active: true) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :available, -> { where('available_quantity > 0') }
  scope :subscription_eligible, -> { where(is_subscription_eligible: true) }
  
  def as_json(options = {})
    super(options.merge(
      except: [:created_at, :updated_at],
      include: {
        category: { only: [:id, :name, :color] }
      }
    ))
  end
  
  def in_stock?
    available_quantity && available_quantity > 0
  end
  
  def low_stock?
    stock_alert_threshold && available_quantity && available_quantity <= stock_alert_threshold
  end
end
