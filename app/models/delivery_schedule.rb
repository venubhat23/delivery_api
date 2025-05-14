class DeliverySchedule < ApplicationRecord
  belongs_to :customer
  belongs_to :user
  has_many :delivery_assignments, dependent: :destroy
  
  validates :frequency, presence: true, inclusion: { in: %w(daily weekly monthly) }
  validates :start_date, presence: true
  
  # Ensure end_date is after start_date if present
  validate :end_date_after_start_date, if: -> { end_date.present? }
  
  private
  
  def end_date_after_start_date
    if end_date <= start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
