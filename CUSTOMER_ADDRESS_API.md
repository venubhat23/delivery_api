# Customer Address API Implementation

This document describes the implementation of the Customer Address API endpoints as requested.

## Overview

The Customer Address API provides endpoints for managing customer addresses with full CRUD operations (Create, Read, Update, Delete).

## Database Schema

The `customer_addresses` table has been created with the following fields:

```sql
CREATE TABLE customer_addresses (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  address_line VARCHAR,
  city VARCHAR,
  state VARCHAR,
  postal_code VARCHAR,
  country VARCHAR,
  phone_number VARCHAR,
  landmark VARCHAR,
  full_address TEXT,
  longitude DECIMAL(10,6),
  latitude DECIMAL(10,6),
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

-- Indexes and constraints
CREATE INDEX index_customer_addresses_on_customer_id ON customer_addresses(customer_id);
ALTER TABLE customer_addresses ADD CONSTRAINT fk_customer_addresses_customer_id 
  FOREIGN KEY (customer_id) REFERENCES customers(id);
```

## API Endpoints

### 1. Create Address

**POST** `/api/v1/customer_address`

Creates a new customer address.

#### Request Body:
```json
{
  "customer_id": 123,
  "address_line": "1234 MG Road",
  "city": "Bangalore",
  "state": "Karnataka",
  "postal_code": "560001",
  "country": "India",
  "phone_number": "9876543210",
  "landmark": "Near Garuda Mall",
  "full_address": "1234 MG Road, Near Garuda Mall, Bangalore - 560001",
  "longitude": 77.5946,
  "latitude": 12.9716
}
```

#### Success Response (201 Created):
```json
{
  "id": 456,
  "customer_id": 123,
  "address_line": "1234 MG Road",
  "city": "Bangalore",
  "state": "Karnataka",
  "postal_code": "560001",
  "country": "India",
  "phone_number": "9876543210",
  "landmark": "Near Garuda Mall",
  "full_address": "1234 MG Road, Near Garuda Mall, Bangalore - 560001",
  "longitude": 77.5946,
  "latitude": 12.9716
}
```

#### Error Response (422 Unprocessable Entity):
```json
{
  "errors": [
    "Customer must exist",
    "Address line can't be blank"
  ]
}
```

### 2. Read/Get Address

**GET** `/api/v1/customer_address/:id`

Retrieves a specific customer address by ID.

#### Example:
`GET /api/v1/customer_address/456`

#### Success Response (200 OK):
```json
{
  "id": 456,
  "customer_id": 123,
  "address_line": "1234 MG Road",
  "city": "Bangalore",
  "state": "Karnataka",
  "postal_code": "560001",
  "country": "India",
  "phone_number": "9876543210",
  "landmark": "Near Garuda Mall",
  "full_address": "1234 MG Road, Near Garuda Mall, Bangalore - 560001",
  "longitude": 77.5946,
  "latitude": 12.9716
}
```

#### Error Response (404 Not Found):
```json
{
  "error": "Customer address not found"
}
```

### 3. Update Address

**PUT/PATCH** `/api/v1/customer_address/:id`

Updates an existing customer address. Supports partial updates.

#### Example:
`PATCH /api/v1/customer_address/456`

#### Request Body:
```json
{
  "address_line": "4321 Residency Road",
  "city": "Bangalore",
  "postal_code": "560025",
  "landmark": "Opposite to Forum Mall",
  "full_address": "4321 Residency Road, Opposite to Forum Mall, Bangalore - 560025",
  "longitude": 77.6101,
  "latitude": 12.9352
}
```

#### Success Response (200 OK):
```json
{
  "id": 456,
  "customer_id": 123,
  "address_line": "4321 Residency Road",
  "city": "Bangalore",
  "state": "Karnataka",
  "postal_code": "560025",
  "country": "India",
  "phone_number": "9876543210",
  "landmark": "Opposite to Forum Mall",
  "full_address": "4321 Residency Road, Opposite to Forum Mall, Bangalore - 560025",
  "longitude": 77.6101,
  "latitude": 12.9352
}
```

### 4. Delete Address (Optional)

**DELETE** `/api/v1/customer_address/:id`

Deletes a customer address.

#### Success Response (200 OK):
```json
{
  "message": "Customer address deleted successfully"
}
```

### 5. List Addresses (Optional)

**GET** `/api/v1/customer_addresses`

Lists customer addresses. Can be filtered by customer_id.

#### Query Parameters:
- `customer_id` (optional): Filter addresses by customer ID

#### Example:
`GET /api/v1/customer_addresses?customer_id=123`

## Implementation Files

### 1. Migration
- **File**: `db/migrate/20250723130247_create_customer_addresses.rb`
- **Purpose**: Creates the customer_addresses table with proper indexes and foreign keys

### 2. Model
- **File**: `app/models/customer_address.rb`
- **Features**:
  - Belongs to Customer relationship
  - Field validations for all required fields
  - Longitude/latitude range validations
  - Geocoding support (reverse geocoding)
  - JSON serialization customization
  - Formatted address helper method

### 3. Controller
- **File**: `app/controllers/api/v1/customer_addresses_controller.rb`
- **Features**:
  - Full CRUD operations
  - Proper error handling
  - Parameter filtering and validation
  - RESTful API responses
  - Follows existing application patterns

### 4. Routes
- **File**: `config/routes.rb`
- **Routes Added**:
  - `POST /api/v1/customer_address`
  - `GET /api/v1/customer_address/:id`
  - `PUT/PATCH /api/v1/customer_address/:id`
  - `DELETE /api/v1/customer_address/:id`
  - `GET /api/v1/customer_addresses`

### 5. Updated Customer Model
- **File**: `app/models/customer.rb`
- **Added**: `has_many :customer_addresses, dependent: :destroy`

## Validations

The CustomerAddress model includes the following validations:

- `customer_id`: Must be present and reference an existing customer
- `address_line`: Must be present
- `city`: Must be present
- `state`: Must be present
- `postal_code`: Must be present
- `country`: Must be present
- `phone_number`: Must be present
- `full_address`: Must be present
- `longitude`: Must be present and between -180 and 180
- `latitude`: Must be present and between -90 and 90

## Testing

A test script has been provided (`test_customer_address_api.rb`) that demonstrates:

1. Creating a new address
2. Reading the created address
3. Updating the address
4. API documentation examples

## Setup Instructions

1. **Run the migration**:
   ```bash
   bundle exec rails db:migrate
   ```

2. **Start the Rails server**:
   ```bash
   bundle exec rails server
   ```

3. **Test the API**:
   ```bash
   ruby test_customer_address_api.rb
   ```

## Error Handling

The API provides proper error responses:

- **400 Bad Request**: Invalid request format
- **404 Not Found**: Address not found
- **422 Unprocessable Entity**: Validation errors
- **500 Internal Server Error**: Server errors

## Security Considerations

- All parameters are properly filtered using strong parameters
- Foreign key constraints ensure data integrity
- Input validation prevents invalid data
- Proper error messages without exposing sensitive information

## Future Enhancements

Potential improvements that could be added:

1. **Authentication**: Add user authentication and authorization
2. **Pagination**: Add pagination for the index endpoint
3. **Search**: Add search functionality by address components
4. **Geocoding**: Automatic address geocoding on create/update
5. **Address Validation**: Integration with address validation services
6. **Audit Trail**: Track address changes with timestamps and user info