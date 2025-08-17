class User < ApplicationRecord
  has_secure_password
  
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: %w(admin delivery_person customer) }
  
  has_one :customer, dependent: :destroy
  has_many :delivery_schedules, foreign_key: 'delivery_person_id', dependent: :restrict_with_error
  has_many :delivery_assignments, foreign_key: 'delivery_person_id', dependent: :restrict_with_error
  has_many :refresh_tokens, dependent: :destroy
  
  def delivery_person?
    role == 'delivery_person'
  end
  
  def customer?
    role == 'customer'
  end
  
  def admin?
    role == 'admin'
  end
end
