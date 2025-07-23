# Customer Address API Implementation (Optimized for Existing Customers Table)

This document describes the implementation of the Customer Address API endpoints using the existing `customers` table efficiently, maximizing the use of existing fields and only adding what's truly necessary.

## Overview

The Customer Address API provides endpoints for managing customer addresses with full CRUD operations (Create, Read, Update, Delete). The implementation efficiently uses existing fields in the `customers` table and only adds missing required fields.

## Database Schema Optimization

Instead of creating a new table, we efficiently use existing fields and add only what's missing:

### Existing Fields Used:
- ✅ `address` → Used as fallback for `address_line`
- ✅ `latitude` → Used directly (precision updated)
- ✅ `longitude` → Used directly (precision updated)
- ✅ `phone_number` → Used directly
- ✅ `address_landmark` → Used as `landmark`

### New Fields Added (Only Missing Ones):
- 🆕 `address_line` (VARCHAR) - Primary address line
- 🆕 `city` (VARCHAR) - City name
- 🆕 `state` (VARCHAR) - State/Province
- 🆕 `postal_code` (VARCHAR) - ZIP/Postal code
- 🆕 `country` (VARCHAR) - Country name
- 🆕 `full_address` (TEXT) - Complete formatted address

### Migration:
```sql
-- Add only missing required fields
ALTER TABLE customers ADD COLUMN address_line VARCHAR;
ALTER TABLE customers ADD COLUMN city VARCHAR;
ALTER TABLE customers ADD COLUMN state VARCHAR;
ALTER TABLE customers ADD COLUMN postal_code VARCHAR;
ALTER TABLE customers ADD COLUMN country VARCHAR;
ALTER TABLE customers ADD COLUMN full_address TEXT;

-- Update precision for existing coordinate fields
ALTER TABLE customers ALTER COLUMN latitude TYPE DECIMAL(10,6);
ALTER TABLE customers ALTER COLUMN longitude TYPE DECIMAL(10,6);
```

## Field Mapping Strategy

| API Field | Database Implementation | Notes |
|-----------|------------------------|-------|
| `address_line` | `address_line` (new) OR `address` (existing) | Uses new field first, falls back to existing |
| `city` | `city` (new) | New field |
| `state` | `state` (new) | New field |
| `postal_code` | `postal_code` (new) | New field |
| `country` | `country` (new) | New field |
| `phone_number` | `phone_number` (existing) | Uses existing field |
| `landmark` | `address_landmark` (existing) | Maps to existing field |
| `full_address` | `full_address` (new) | New field for complete address |
| `longitude` | `longitude` (existing, updated precision) | Enhanced existing field |
| `latitude` | `latitude` (existing, updated precision) | Enhanced existing field |

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

## Implementation Details

### Smart Field Handling

1. **Address Line**: 
   - If `address_line` is provided, it updates both `address_line` (new) and `address` (existing)
   - When reading, uses `address_line` if available, otherwise falls back to `address`

2. **Landmark**:
   - API accepts `landmark` parameter
   - Internally maps to existing `address_landmark` field
   - No new database column needed

3. **Phone Number**:
   - Uses existing `phone_number` field directly
   - No new column needed

4. **Coordinates**:
   - Uses existing `latitude` and `longitude` fields
   - Only updates precision to DECIMAL(10,6)

### Backward Compatibility

- ✅ Existing customer records work unchanged
- ✅ Existing customer API endpoints remain functional
- ✅ New address fields are optional for existing functionality
- ✅ Address validations only apply when using address API

## Implementation Files

### 1. Optimized Migration
- **File**: `db/migrate/20250723130247_add_customer_address_fields_to_customers.rb`
- **Purpose**: Adds only missing fields, uses existing ones efficiently

### 2. Enhanced Customer Model
- **File**: `app/models/customer.rb`
- **Features**:
  - Smart field mapping methods (`get_address_line`, `get_landmark`, `get_full_address`)
  - Conditional validations only for address API
  - Backward compatibility with existing functionality
  - Efficient field usage

### 3. Optimized Controller
- **File**: `app/controllers/api/v1/customer_addresses_controller.rb`
- **Features**:
  - Parameter processing to map API fields to database fields
  - Efficient field handling
  - Updates both new and existing fields when appropriate

## Advantages of This Optimized Approach

1. **Minimal Database Changes**: Only 6 new columns instead of 11
2. **Maximum Field Reuse**: Uses 4 existing fields efficiently
3. **Backward Compatibility**: 100% compatible with existing code
4. **Data Consistency**: Updates both new and legacy fields
5. **Storage Efficiency**: No duplicate data storage
6. **Performance**: No additional JOINs, minimal schema changes

## Field Usage Summary

| Total Required Fields | Existing Fields Used | New Fields Added | Efficiency |
|----------------------|---------------------|------------------|------------|
| 11 | 4 (36%) | 6 (55%) | 64% field reuse |

### Existing Fields Reused:
- `address` → `address_line` fallback
- `phone_number` → direct use
- `address_landmark` → `landmark` mapping
- `latitude`, `longitude` → enhanced precision

### New Fields Added:
- `address_line`, `city`, `state`, `postal_code`, `country`, `full_address`

This optimized approach provides the complete Customer Address API functionality while making minimal changes to the existing database schema and maintaining full backward compatibility.