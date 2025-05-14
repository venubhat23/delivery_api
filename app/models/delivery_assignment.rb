class DeliveryAssignment < ApplicationRecord
  belongs_to :delivery_schedule
  belongs_to :customer
  belongs_to :user
  has_many :delivery_items, dependent: :destroy
  belongs_to :product

  validates :scheduled_date, presence: true
  validates :status, inclusion: { in: %w(pending in_progress completed cancelled) }
  
  # Ensure completed_at is present when status is completed
  validates :completed_at, presence: true, if: -> { status == 'completed' }
  
  scope :pending_today, -> { where(scheduled_date: Date.today, status: 'pending') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :completed_today, -> { where(scheduled_date: Date.today, status: 'completed') }

end
