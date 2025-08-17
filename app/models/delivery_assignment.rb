class DeliveryAssignment < ApplicationRecord
  belongs_to :delivery_schedule, optional: true
  belongs_to :customer
  belongs_to :user
  belongs_to :product
  belongs_to :invoice, optional: true
  has_many :delivery_items, dependent: :destroy

  validates :scheduled_date, presence: true
  validates :status, inclusion: { in: %w(pending in_progress completed cancelled scheduled skipped_vacation cancelled_user delivered failed) }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit, presence: true
  
  # Ensure completed_at is present when status is completed
  validates :completed_at, presence: true, if: -> { status == 'completed' }
  
  scope :pending_today, -> { where(scheduled_date: Date.today, status: 'pending') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :completed_today, -> { where(scheduled_date: Date.today, status: 'completed') }
  scope :by_customer, ->(customer_id) { where(customer_id: customer_id) }
  scope :by_delivery_person, ->(user_id) { where(user_id: user_id) }
  scope :by_date_range, ->(start_date, end_date) { where(scheduled_date: start_date..end_date) }
  scope :invoice_pending, -> { where(invoice_generated: false) }
  scope :scheduled, -> { where(status: 'scheduled') }
  scope :skipped_vacation, -> { where(status: 'skipped_vacation') }
  
  def as_json(options = {})
    super(options.merge(
      except: [:created_at, :updated_at],
      include: {
        customer: { only: [:id, :name, :address, :phone_number] },
        user: { only: [:id, :name, :phone] },
        product: { only: [:id, :name, :unit_type, :price] },
        invoice: { only: [:id, :invoice_number, :total_amount, :status] }
      }
    ))
  end
  
  def total_amount
    return 0 unless product && quantity
    product.price * quantity
  end
  
  def can_be_completed?
    status == 'in_progress'
  end
  
  def can_be_started?
    (status == 'pending' || status == 'scheduled') && scheduled_date <= Date.today
  end
  
  def overdue?
    (status == 'pending' || status == 'scheduled') && scheduled_date < Date.today
  end

  def skipped_for_vacation?
    status == 'skipped_vacation'
  end
end
