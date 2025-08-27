class Faq < ApplicationRecord
  validates :question, presence: true
  validates :answer, presence: true
  validates :locale, presence: true

  scope :active, -> { where(is_active: true) }
  scope :published, -> { where(is_active: true) }
  scope :for_locale, ->(loc) { where(locale: loc.presence || 'en') }
  scope :ordered, -> { order(:sort_order, :id) }
end