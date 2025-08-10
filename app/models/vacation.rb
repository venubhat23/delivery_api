class Vacation < ApplicationRecord
  belongs_to :customer

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :valid_date_range

  scope :for_customer, ->(customer_id) { where(customer_id: customer_id) }
  scope :upcoming, -> { where("end_date >= ?", Date.today) }

  def date_range
    (start_date..end_date)
  end

  private

  def valid_date_range
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "must be on or after start_date") if end_date < start_date
  end
end