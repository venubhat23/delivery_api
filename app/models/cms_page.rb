class CmsPage < ApplicationRecord
  validates :slug, presence: true
  validates :version, presence: true
  validates :title, presence: true
  validates :content, presence: true
  validates :locale, presence: true

  scope :published, -> { where.not(published_at: nil) }
  scope :for_slug, ->(slug) { where(slug: slug) }
  scope :for_locale, ->(loc) { where(locale: loc.presence || 'en') }
end