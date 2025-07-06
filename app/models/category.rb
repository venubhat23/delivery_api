class Category < ApplicationRecord
  has_many :products, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  validates :color, presence: true
  
  scope :active, -> { where(is_active: true) }
  
  def as_json(options = {})
    super(options.merge(
      except: [:created_at, :updated_at]
    ))
  end
end