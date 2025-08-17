class UserVacation < ApplicationRecord
  belongs_to :customer
  belongs_to :created_by, class_name: 'User', optional: true

  STATUSES = %w[active paused cancelled completed].freeze

  validates :start_date, :end_date, presence: true
  validates :status, inclusion: { in: STATUSES }
  validate :validate_date_range
  validate :validate_overlap, on: :create

  scope :for_customer, ->(customer_id) { where(customer_id: customer_id) }
  scope :overlapping, ->(start_date, end_date) {
    where('(start_date <= ?) AND (end_date >= ?)', end_date, start_date)
  }
  scope :active_or_paused, -> { where(status: %w[active paused]) }

  def as_json(options = {})
    super(options.merge(except: [:created_at, :updated_at], methods: []))
  end

  private

  def validate_date_range
    return if start_date.blank? || end_date.blank?
    if end_date < start_date
      errors.add(:end_date, 'must be on or after start_date')
    end
  end

  def validate_overlap
    return if start_date.blank? || end_date.blank?
    return if @skip_overlap_validation
    if UserVacation.for_customer(customer_id).active_or_paused.overlapping(start_date, end_date).exists?
      errors.add(:base, 'overlaps with an existing active/paused vacation')
    end
  end

  public
  # Allow controller to bypass overlap check when merging
  def skip_overlap_validation!
    @skip_overlap_validation = true
  end
end