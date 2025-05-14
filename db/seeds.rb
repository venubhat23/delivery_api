# Clear existing data
DeliveryItem.delete_all
Delivery.delete_all
Product.delete_all
Customer.delete_all
User.delete_all

# Create sample products
milk_regular = Product.create!(name: 'Regular Cow Milk', description: 'Fresh cow milk')
milk_premium = Product.create!(name: 'Premium Buffalo Milk', description: 'Fresh buffalo milk')
milk_toned = Product.create!(name: 'Toned Milk', description: 'Toned milk with 3% fat')

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

# Create deliveries for today
today = Date.today

# Delivery for customer 1
delivery1 = Delivery.create!(
  customer: customer1,
  delivery_person_id: delivery_person.id,
  status: 'pending',
  delivery_date: today
)

DeliveryItem.create!(
  delivery: delivery1,
  product: milk_regular,
  quantity: 2
)

# Delivery for customer 2
delivery2 = Delivery.create!(
  customer: customer2,
  delivery_person_id: delivery_person.id,
  status: 'pending',
  delivery_date: today
)

DeliveryItem.create!(
  delivery: delivery2,
  product: milk_premium,
  quantity: 1
)

# Delivery for customer 3
delivery3 = Delivery.create!(
  customer: customer3,
  delivery_person_id: delivery_person.id,
  status: 'pending',
  delivery_date: today
)

DeliveryItem.create!(
  delivery: delivery3,
  product: milk_regular,
  quantity: 1.5
)

DeliveryItem.create!(
  delivery: delivery3,
  product: milk_toned,
  quantity: 1
)

puts "Seed data created successfully!"
