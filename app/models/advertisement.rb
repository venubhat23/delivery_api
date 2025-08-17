class Advertisement < ApplicationRecord
  belongs_to :user

  STATUSES = %w[active inactive archived].freeze

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :status, inclusion: { in: STATUSES }
  validate :end_date_not_before_start_date

  scope :active_now, -> { where(status: 'active').where('start_date <= ? AND end_date >= ?', Date.today, Date.today) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }

  private

  def end_date_not_before_start_date
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "can't be before start_date") if end_date < start_date
  end
end