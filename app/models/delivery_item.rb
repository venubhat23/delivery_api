class DeliveryItem < ApplicationRecord
  belongs_to :delivery_assignment
  belongs_to :product
  
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  
  # Ensure there's enough product quantity available
  validate :product_quantity_available, on: :create
  
  private
  
  def product_quantity_available
    return unless product && quantity
    
    if quantity > product.available_quantity
      errors.add(:quantity, "exceeds available product quantity (#{product.available_quantity} #{product.unit_type})")
    end
  end

end
