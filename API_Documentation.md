# Milk Delivery Booking System API Documentation

## Overview

This is a comprehensive milk delivery booking system API that supports both single-day orders and multi-day subscriptions. The system is designed to handle customer orders, delivery scheduling, and inventory management.

## System Architecture

### Core Components

1. **Customer App (delivery_app)** - Frontend for customers to place orders and manage subscriptions
2. **Delivery API (delivery_api)** - Backend API for order management and delivery operations
3. **Shared Database** - PostgreSQL database shared between both applications

### Key Terminology

- **Order** = Single-day delivery request
- **Subscription** = Multi-day delivery schedule with recurring deliveries
- **Delivery Schedule** = The overall plan for recurring deliveries
- **Delivery Assignment** = Individual delivery task for a specific date

## Database Schema

### Main Tables

- `categories` - Product categories (Milk Products, Dairy Products, etc.)
- `products` - Available products with pricing and inventory
- `customers` - Customer information and preferences
- `delivery_schedules` - Recurring delivery plans
- `delivery_assignments` - Individual delivery tasks
- `invoices` & `invoice_items` - Billing information

## API Endpoints

### Base URL
```
http://localhost:3000/api/v1
```

### Authorization
All API endpoints (except authentication endpoints) require a Bearer token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

**Authentication Flow:**
1. For customers: Use `/customer_login` endpoint which validates against Customer model
2. For admin/delivery_person: Use `/login` endpoint with role parameter
3. Use the returned JWT token in the Authorization header for subsequent API calls
4. For customer signup: Both User and Customer records are created automatically

### Authentication

#### POST `/login`
Login endpoint for admin and delivery_person users
```json
{
  "phone": "+919876543210",
  "password": "password123",
  "role": "admin"
}
```

Response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "name": "Admin User",
    "role": "admin",
    "email": "admin@example.com",
    "phone": "+919876543210"
  }
}
```

#### POST `/customer_login`
Login endpoint specifically for customers (checks Customer model)
```json
{
  "phone": "+919876543220",
  "password": "password123"
}
```

Response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 2,
    "name": "Customer User",
    "role": "customer",
    "email": "customer@example.com",
    "phone": "+919876543220"
  },
  "customer": {
    "id": 1,
    "name": "Customer Name",
    "address": "123 Main St, City",
    "phone_number": "+919876543220",
    "email": "customer@example.com",
    "preferred_language": "en",
    "delivery_time_preference": "morning",
    "notification_method": "sms"
  }
}
```

#### POST `/signup`
User registration endpoint
For customers (role: "customer"):
```json
{
  "name": "Test Customer",
  "email": "customer@example.com",
  "phone": "+919876543220",
  "password": "password123",
  "role": "customer",
  "address": "123 Main St, City",
  "latitude": 12.9716,
  "longitude": 77.5946,
  "phone_number": "+919876543220",
  "preferred_language": "en",
  "delivery_time_preference": "morning",
  "notification_method": "sms"
}
```

For admin/delivery_person:
```json
{
  "name": "Admin User",
  "email": "admin@example.com",
  "phone": "+919876543210",
  "password": "password123",
  "role": "admin"
}
```

Response (for customer):
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 2,
    "name": "Test Customer",
    "role": "customer",
    "email": "customer@example.com",
    "phone": "+919876543220"
  },
  "customer": {
    "id": 1,
    "name": "Test Customer",
    "address": "123 Main St, City",
    "phone_number": "+919876543220",
    "email": "customer@example.com",
    "latitude": 12.9716,
    "longitude": 77.5946
  }
}
```

### Categories & Products

#### GET `/categories`
Get all product categories
- **Headers:** `Authorization: Bearer <token>`
- Returns: Array of categories with id, name, description, and color

#### GET `/products`
Get all products with optional filtering
- **Headers:** `Authorization: Bearer <token>`
- **Query Parameters:**
  - `category_id` - Filter by category
  - `available=true` - Only available products
  - `subscription_eligible=true` - Only subscription-eligible products
  - `search=milk` - Search products by name
- Returns: Array of products with pricing, inventory, and category information

#### GET `/products/low_stock`
Get products with low stock levels
- Returns: Products below their stock alert threshold

### Orders (Single-day Deliveries)

#### POST `/place_order`
Place a single-day order
- **Headers:** `Authorization: Bearer <token>`
```json
{
  "customer_id": 1,
  "product_id": 1,
  "quantity": 2,
  "unit": "liters",
  "delivery_date": "2025-01-07"
}
```

#### GET `/orders`
Get orders with optional filtering
- **Headers:** `Authorization: Bearer <token>`
- **Query Parameters:**
  - `customer_id` - Filter by customer
- Returns: Array of orders with delivery details

### Subscriptions (Multi-day Deliveries)

#### POST `/subscriptions`
Create a subscription
```json
{
  "customer_id": 1,
  "product_id": 1,
  "frequency": "daily",
  "start_date": "2025-01-07",
  "end_date": "2025-01-14",
  "quantity": 1.5,
  "unit": "liters"
}
```

#### GET `/subscriptions`
Get subscriptions with optional filtering
- **Query Parameters:**
  - `customer_id` - Filter by customer

#### PUT `/subscriptions/:id`
Update subscription details
```json
{
  "quantity": 2.5,
  "end_date": "2025-01-21"
}
```

#### DELETE `/subscriptions/:id`
Cancel a subscription

### Customer Management

#### GET `/customers`
Get all customers

#### GET `/customers/:id`
Get customer details

#### POST `/customers`
Create a new customer
```json
{
  "name": "New Customer",
  "address": "123 Main St, City",
  "phone_number": "+919876543221",
  "email": "newcustomer@example.com",
  "latitude": 12.9716,
  "longitude": 77.5946,
  "user_id": 1
}
```

#### PUT `/customers/:id/settings`
Update customer settings
```json
{
  "phone_number": "+919876543222",
  "preferred_language": "en",
  "delivery_time_preference": "morning",
  "notification_method": "sms",
  "alt_phone_number": "+919876543223"
}
```

#### POST `/customers/:id/update_location`
Update customer location
```json
{
  "latitude": 12.9716,
  "longitude": 77.5946,
  "address": "Updated Address, City"
}
```

### Delivery Assignments

#### GET `/delivery_assignments`
Get all delivery assignments
- **Query Parameters:**
  - `customer_id` - Filter by customer

#### GET `/delivery_assignments/today`
Get today's delivery assignments

#### GET `/delivery_assignments/:id`
Get delivery assignment details

#### POST `/delivery_assignments/start_nearest`
Start the nearest delivery assignment
```json
{
  "current_latitude": 12.9716,
  "current_longitude": 77.5946
}
```

#### POST `/delivery_assignments/:id/complete`
Complete a delivery assignment
```json
{
  "delivery_notes": "Delivered successfully",
  "actual_quantity": 2.0
}
```

### Delivery Schedules (Admin)

#### GET `/delivery_schedules`
Get all delivery schedules

#### GET `/delivery_schedules/:id`
Get delivery schedule details

#### POST `/delivery_schedules`
Create a new delivery schedule
```json
{
  "customer_id": 1,
  "user_id": 1,
  "product_id": 1,
  "frequency": "daily",
  "start_date": "2025-01-07",
  "end_date": "2025-01-14",
  "default_quantity": 2.0,
  "default_unit": "liters"
}
```

#### PUT `/delivery_schedules/:id`
Update delivery schedule

#### DELETE `/delivery_schedules/:id`
Delete delivery schedule

## Business Logic

### Order Processing

1. **Single-day Orders:**
   - Creates a `DeliverySchedule` with frequency="daily" and 1-day duration
   - Creates corresponding `DeliveryAssignment` for the delivery date
   - Validates product availability and customer details

2. **Multi-day Subscriptions:**
   - Creates a `DeliverySchedule` with specified frequency and duration
   - Automatically generates multiple `DeliveryAssignment` records based on frequency
   - Supports daily, weekly, and monthly frequencies

### Delivery Assignment Creation

- **Daily**: Creates assignments for each day in the date range
- **Weekly**: Creates assignments for each week (e.g., every Monday)
- **Monthly**: Creates assignments for each month (e.g., 1st of each month)

### Inventory Management

- Stock levels are tracked in the `products` table
- Stock alerts are triggered when `available_quantity` <= `stock_alert_threshold`
- Orders are validated against available stock

### Customer Preferences

- Language preferences (preferred_language)
- Delivery time preferences (delivery_time_preference)
- Notification methods (notification_method)
- Alternative contact information (alt_phone_number)

## Data Models

### Product
```ruby
{
  id: integer,
  name: string,
  description: string,
  price: decimal,
  unit_type: string,
  available_quantity: decimal,
  category_id: integer,
  is_subscription_eligible: boolean,
  stock_alert_threshold: integer,
  is_active: boolean
}
```

### Customer
```ruby
{
  id: integer,
  name: string,
  address: string,
  phone_number: string,
  email: string,
  latitude: decimal,
  longitude: decimal,
  preferred_language: string,
  delivery_time_preference: string,
  notification_method: string,
  is_active: boolean
}
```

### DeliverySchedule
```ruby
{
  id: integer,
  customer_id: integer,
  user_id: integer,
  product_id: integer,
  frequency: string, # "daily", "weekly", "monthly"
  start_date: date,
  end_date: date,
  default_quantity: decimal,
  default_unit: string,
  status: string
}
```

### DeliveryAssignment
```ruby
{
  id: integer,
  delivery_schedule_id: integer,
  customer_id: integer,
  user_id: integer,
  product_id: integer,
  scheduled_date: date,
  quantity: decimal,
  unit: string,
  status: string, # "pending", "in_progress", "completed", "cancelled"
  completed_at: datetime
}
```

## Error Handling

All API endpoints return appropriate HTTP status codes:

- `200 OK` - Successful requests
- `201 Created` - Successful creation
- `400 Bad Request` - Invalid request parameters
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation errors
- `500 Internal Server Error` - Server errors

Error responses include detailed error messages:
```json
{
  "error": "Validation failed",
  "details": {
    "price": ["can't be blank"],
    "quantity": ["must be greater than 0"]
  }
}
```

## Setup Instructions

### Prerequisites
- Ruby 3.3.7
- PostgreSQL 12+
- Rails 7.1+

### Installation
1. Clone the repository
2. Install dependencies: `bundle install`
3. Setup database: `rails db:create db:migrate db:seed`
4. Start server: `rails server`

### Database Configuration
Update `config/database.yml` with your PostgreSQL credentials:
```yaml
development:
  adapter: postgresql
  database: mahadev_db3
  username: mahadev_user
  password: mahadev_password
  host: localhost
  port: 5432
```

### Testing with Postman
1. Import the provided `postman_collection.json` file
2. Update the base URL variable if needed
3. Test authentication endpoints first
4. Use the collection variables for customer_id and user_id

## Advanced Features

### Geolocation Support
- Customer locations stored with latitude/longitude
- Delivery assignment routing based on proximity
- Location-based delivery optimization

### Subscription Management
- Flexible frequency options (daily, weekly, monthly)
- Subscription pause/resume functionality
- Automatic delivery assignment generation

### Inventory Tracking
- Real-time stock level monitoring
- Low stock alerts for administrators
- Stock allocation for confirmed orders

### Customer Preferences
- Multiple language support
- Delivery time preferences
- Notification preferences (SMS, email, push)

## Future Enhancements

1. **Payment Integration** - Add payment processing capabilities
2. **Push Notifications** - Real-time delivery updates
3. **Route Optimization** - AI-powered delivery route planning
4. **Analytics Dashboard** - Business intelligence and reporting
5. **Mobile App API** - Enhanced mobile application support

## Support

For API support or questions, please contact the development team or refer to the inline code documentation.