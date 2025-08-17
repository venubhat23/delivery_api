class SupportTicket < ApplicationRecord
  belongs_to :customer, optional: true

  validates :message, presence: true
  validates :channel, inclusion: { in: %w(app web email) }
  validates :status, inclusion: { in: %w(open pending closed) }
end