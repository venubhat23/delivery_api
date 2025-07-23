# Customer Address API Implementation (Using Customers Table)

This document describes the implementation of the Customer Address API endpoints using the existing `customers` table instead of creating a separate table.

## Overview

The Customer Address API provides endpoints for managing customer addresses with full CRUD operations (Create, Read, Update, Delete). The implementation uses the existing `customers` table and adds the missing address fields as new columns.

## Database Schema Changes

Instead of creating a new table, we add missing fields to the existing `customers` table:

### Existing Fields in Customers Table:
- `address` (existing)
- `latitude` (existing) 
- `longitude` (existing)
- `address_landmark` (existing)
- `address_type` (existing)
- `phone_number` (existing)

### New Fields Added:
- `address_line` (VARCHAR)
- `city` (VARCHAR)
- `state` (VARCHAR)
- `postal_code` (VARCHAR)
- `country` (VARCHAR)
- `landmark` (VARCHAR)
- `full_address` (TEXT)

### Migration:
```sql
-- Add missing columns to customers table
ALTER TABLE customers ADD COLUMN address_line VARCHAR;
ALTER TABLE customers ADD COLUMN city VARCHAR;
ALTER TABLE customers ADD COLUMN state VARCHAR;
ALTER TABLE customers ADD COLUMN postal_code VARCHAR;
ALTER TABLE customers ADD COLUMN country VARCHAR;
ALTER TABLE customers ADD COLUMN landmark VARCHAR;
ALTER TABLE customers ADD COLUMN full_address TEXT;

-- Update precision for coordinates
ALTER TABLE customers ALTER COLUMN latitude TYPE DECIMAL(10,6);
ALTER TABLE customers ALTER COLUMN longitude TYPE DECIMAL(10,6);
```

## API Endpoints

### 1. Create/Update Address

**POST** `/api/v1/customer_address`

Creates or updates address information for an existing customer.

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
  "id": 123,
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

#### Error Responses:
```json
// Customer not found
{
  "errors": ["Customer not found"]
}

// Validation errors
{
  "errors": [
    "Address line can't be blank",
    "City can't be blank"
  ]
}
```

### 2. Read/Get Address

**GET** `/api/v1/customer_address/:customer_id`

Retrieves address information for a specific customer.

#### Example:
`GET /api/v1/customer_address/123`

#### Success Response (200 OK):
```json
{
  "id": 123,
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
  "error": "Customer not found"
}
```

### 3. Update Address

**PUT/PATCH** `/api/v1/customer_address/:customer_id`

Updates address information for an existing customer. Supports partial updates.

#### Example:
`PATCH /api/v1/customer_address/123`

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
  "id": 123,
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

### 4. Clear Address (Optional)

**DELETE** `/api/v1/customer_address/:customer_id`

Clears address information for a customer (sets address fields to null).

#### Success Response (200 OK):
```json
{
  "message": "Customer address cleared successfully"
}
```

### 5. List Customer Addresses (Optional)

**GET** `/api/v1/customer_addresses`

Lists customer addresses with optional filtering.

#### Query Parameters:
- `customer_id` (optional): Get address for specific customer

#### Examples:
- `GET /api/v1/customer_addresses?customer_id=123` - Get address for customer 123
- `GET /api/v1/customer_addresses` - Get addresses for all active customers

## Implementation Files

### 1. Migration
- **File**: `db/migrate/20250723130247_add_customer_address_fields_to_customers.rb`
- **Purpose**: Adds missing address fields to the existing customers table

### 2. Updated Customer Model
- **File**: `app/models/customer.rb`
- **Features**:
  - Conditional address validations (only when `address_api_context` is true)
  - Special JSON formatting for address API responses
  - Automatic full_address generation from components
  - Longitude/latitude range validations
  - Backward compatibility with existing customer functionality

### 3. Controller
- **File**: `app/controllers/api/v1/customer_addresses_controller.rb`
- **Features**:
  - Works with existing Customer model
  - Full CRUD operations on customer address fields
  - Proper error handling for customer not found
  - Parameter filtering and validation
  - Uses customer ID as the primary identifier

### 4. Routes
- **File**: `config/routes.rb`
- **Routes**:
  - `POST /api/v1/customer_address`
  - `GET /api/v1/customer_address/:customer_id`
  - `PUT/PATCH /api/v1/customer_address/:customer_id`
  - `DELETE /api/v1/customer_address/:customer_id`
  - `GET /api/v1/customer_addresses`

## Key Differences from Separate Table Approach

1. **No Separate Model**: Uses existing Customer model with additional fields
2. **Customer ID as Primary Key**: The `:id` parameter refers to customer ID, not address ID
3. **Conditional Validations**: Address validations only apply when updating via address API
4. **Field Mapping**: Maps new fields to existing fields where possible (e.g., `landmark` falls back to `address_landmark`)
5. **Backward Compatibility**: Existing customer functionality remains unchanged

## Validations

Address validations are applied only when `address_api_context` is set to true:

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

1. Creating/updating address for an existing customer
2. Reading the customer's address
3. Updating the customer's address
4. API documentation examples

**Important**: The test script requires an existing customer ID. Update the `customer_id` variable in the script.

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
   # First, make sure you have existing customers in the database
   # Update the customer_id in the test script
   ruby test_customer_address_api.rb
   ```

## Advantages of This Approach

1. **No Additional Table**: Utilizes existing customers table
2. **Simpler Relationships**: No need for separate model relationships
3. **Backward Compatibility**: Existing customer API remains unchanged
4. **Data Consistency**: All customer data in one place
5. **Performance**: No additional JOINs required

## Usage Notes

- The `customer_id` in POST requests must refer to an existing customer
- The URL parameter `:id` refers to the customer ID, not a separate address ID
- Address validations only apply when using the address API endpoints
- Existing customer endpoints continue to work without address validations
- The `landmark` field will fall back to `address_landmark` if not set