class SupportTicket < ApplicationRecord
  belongs_to :customer, optional: true

  validates :message, presence: true
  validates :channel, inclusion: { in: %w(app web email) }
  validates :status, inclusion: { in: %w(open pending closed) }

  scope :recent, -> { order(created_at: :desc) }
  scope :open_tickets, -> { where(status: ['open', 'pending']) }

  def days_open
    return 0 if resolved_at.present?
    ((Time.current - created_at) / 1.day).to_i
  end
end