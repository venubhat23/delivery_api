class Invoice < ApplicationRecord
  belongs_to :customer
  has_many :invoice_items, dependent: :destroy
  has_many :delivery_assignments, dependent: :nullify
  has_many :products, through: :invoice_items
  
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[draft pending paid overdue cancelled] }
  validates :invoice_date, presence: true
  validates :invoice_number, presence: true, uniqueness: true
  validates :invoice_type, inclusion: { in: %w[manual automatic] }
  validates :phone_number, format: { with: /\A[0-9]{10}\z/, message: "must be 10 digits" }, allow_blank: true
  
  scope :pending, -> { where(status: 'pending') }
  scope :paid, -> { where(status: 'paid') }
  scope :overdue, -> { where(status: 'overdue') }
  scope :by_date_range, ->(start_date, end_date) { where(invoice_date: start_date..end_date) }
  scope :by_customer, ->(customer_id) { where(customer_id: customer_id) }
  
  before_validation :generate_invoice_number, if: -> { invoice_number.blank? }
  before_save :calculate_due_date, if: -> { due_date.blank? && invoice_date.present? }
  
  def as_json(options = {})
    super(options.merge(
      except: [:created_at, :updated_at],
      include: {
        customer: { only: [:id, :name, :address, :phone_number, :email] },
        invoice_items: {
          include: {
            product: { only: [:id, :name, :unit_type] }
          }
        }
      }
    ))
  end
  
  def mark_as_paid!
    update!(status: 'paid', paid_at: Time.current)
  end
  
  def overdue?
    due_date && due_date < Date.today && status != 'paid'
  end
  
  def days_overdue
    return 0 unless overdue?
    (Date.today - due_date).to_i
  end
  
  def total_items
    invoice_items.sum(:quantity)
  end
  
  private
  
  def generate_invoice_number
    last_invoice = Invoice.order(:id).last
    next_number = last_invoice ? last_invoice.id + 1 : 1
    self.invoice_number = "INV#{Date.today.strftime('%Y%m%d')}#{next_number.to_s.rjust(4, '0')}"
  end
  
  def calculate_due_date
    self.due_date = invoice_date + 7.days
  end
end