class Product < ApplicationRecord
  has_many :delivery_items
  has_many :deliveries, through: :delivery_items
  has_many :delivery_assignments

  validates :name, presence: true
end
