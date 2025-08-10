class Advertisement < ApplicationRecord
  belongs_to :user

  STATUSES = %w[active inactive archived].freeze

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :status, inclusion: { in: STATUSES }
  validate :start_date_before_end_date

  scope :active, -> { where(status: 'active') }
  scope :current, -> { where("start_date <= ? AND end_date >= ?", Date.today, Date.today) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }

  def as_json(options = {})
    super(options.merge(
      only: [:id, :name, :image_url, :start_date, :end_date, :status],
      methods: []
    ))
  end

  private

  def start_date_before_end_date
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "must be after start_date") if end_date < start_date
  end
end