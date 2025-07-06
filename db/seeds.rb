# Clear existing data (in correct order to avoid foreign key violations)
DeliveryItem.delete_all
DeliveryAssignment.delete_all
DeliverySchedule.delete_all
Delivery.delete_all
Product.delete_all
Customer.delete_all
User.delete_all
Category.delete_all

# Create categories
milk_category = Category.create!(
  name: 'Milk Products',
  description: 'Fresh milk and dairy products',
  color: '#4CAF50'
)

dairy_category = Category.create!(
  name: 'Dairy Products',
  description: 'Dairy products like yogurt, cheese, etc.',
  color: '#2196F3'
)

# Create sample products
milk_regular = Product.create!(
  name: 'Regular Cow Milk',
  description: 'Fresh cow milk',
  price: 25.00,
  unit_type: 'liters',
  available_quantity: 100,
  category: milk_category,
  is_subscription_eligible: true,
  stock_alert_threshold: 10
)

milk_premium = Product.create!(
  name: 'Premium Buffalo Milk',
  description: 'Fresh buffalo milk',
  price: 35.00,
  unit_type: 'liters',
  available_quantity: 50,
  category: milk_category,
  is_subscription_eligible: true,
  stock_alert_threshold: 5
)

milk_toned = Product.create!(
  name: 'Toned Milk',
  description: 'Toned milk with 3% fat',
  price: 22.00,
  unit_type: 'liters',
  available_quantity: 75,
  category: milk_category,
  is_subscription_eligible: true,
  stock_alert_threshold: 8
)

# Create admin user
admin = User.create!(
  name: 'Admin User',
  email: 'admin@example.com',
  phone: '+919999999999',
  password: 'password123',
  role: 'admin'
)

# Create delivery personnel
delivery_person = User.create!(
  name: 'Ravi Sharma',
  email: 'ravi@example.com',
  phone: '+919876543210',
  password: 'password123',
  role: 'delivery_person'
)

# Create customers with users
customer1_user = User.create!(
  name: 'Anil Kumar',
  email: 'anil@example.com',
  phone: '+919876543211',
  password: 'password123',
  role: 'customer'
)

customer1 = Customer.create!(
  name: 'Anil Kumar',
  address: '123, 3rd Cross, JP Nagar, Bangalore',
  latitude: 12.9361,
  longitude: 77.6101,
  user: customer1_user
)

customer2_user = User.create!(
  name: 'Sunita Rao',
  email: 'sunita@example.com',
  phone: '+919876543212',
  password: 'password123',
  role: 'customer'
)

customer2 = Customer.create!(
  name: 'Sunita Rao',
  address: '22, Main Street, Koramangala',
  latitude: 12.9380,
  longitude: 77.6125,
  user: customer2_user
)

customer3_user = User.create!(
  name: 'Ramesh Joshi',
  email: 'ramesh@example.com',
  phone: '+919876543213',
  password: 'password123',
  role: 'customer'
)

customer3 = Customer.create!(
  name: 'Ramesh Joshi',
  address: '45, 5th Block, Jayanagar',
  latitude: 12.9300,
  longitude: 77.5950,
  user: customer3_user
)

# Create delivery schedules and assignments for today
today = Date.today

# Delivery schedule for customer 1 (single day order)
schedule1 = DeliverySchedule.create!(
  customer: customer1,
  user: admin,
  product: milk_regular,
  frequency: 'daily',
  start_date: today,
  end_date: today + 1.day,
  status: 'active',
  default_quantity: 2.0,
  default_unit: 'liters'
)

# Delivery assignment for customer 1
assignment1 = DeliveryAssignment.create!(
  delivery_schedule: schedule1,
  customer: customer1,
  user: admin,
  scheduled_date: today,
  product: milk_regular,
  quantity: 2.0,
  unit: 'liters',
  status: 'pending'
)

# Delivery schedule for customer 2 (single day order)
schedule2 = DeliverySchedule.create!(
  customer: customer2,
  user: admin,
  product: milk_premium,
  frequency: 'daily',
  start_date: today,
  end_date: today + 1.day,
  status: 'active',
  default_quantity: 1.0,
  default_unit: 'liters'
)

# Delivery assignment for customer 2
assignment2 = DeliveryAssignment.create!(
  delivery_schedule: schedule2,
  customer: customer2,
  user: admin,
  scheduled_date: today,
  product: milk_premium,
  quantity: 1.0,
  unit: 'liters',
  status: 'pending'
)

# Delivery schedule for customer 3 (subscription - weekly)
schedule3 = DeliverySchedule.create!(
  customer: customer3,
  user: admin,
  product: milk_regular,
  frequency: 'weekly',
  start_date: today,
  end_date: today + 4.weeks,
  status: 'active',
  default_quantity: 1.5,
  default_unit: 'liters'
)

# Delivery assignment for customer 3 (first delivery)
assignment3 = DeliveryAssignment.create!(
  delivery_schedule: schedule3,
  customer: customer3,
  user: admin,
  scheduled_date: today,
  product: milk_regular,
  quantity: 1.5,
  unit: 'liters',
  status: 'pending'
)

# Another delivery assignment for customer 3 (next week)
assignment4 = DeliveryAssignment.create!(
  delivery_schedule: schedule3,
  customer: customer3,
  user: admin,
  scheduled_date: today + 7.days,
  product: milk_regular,
  quantity: 1.5,
  unit: 'liters',
  status: 'pending'
)

puts "Seed data created successfully!"
