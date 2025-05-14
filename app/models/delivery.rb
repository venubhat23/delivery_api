class Delivery < ApplicationRecord
  belongs_to :customer
  has_many :delivery_items, dependent: :destroy
  has_many :products, through: :delivery_items
  
  validates :status, presence: true, inclusion: { in: %w(pending in_progress completed) }
  validates :delivery_date, presence: true
  
  def delivery_person
    User.find_by(id: delivery_person_id)
  end
  
  def as_json(options = {})
    super(options.merge(
      except: [:created_at, :updated_at],
      include: {
        customer: { except: [:created_at, :updated_at] },
        delivery_items: {
          include: {
            product: { only: [:id, :name] }
          },
          except: [:created_at, :updated_at]
        }
      }
    ))
  end
end
