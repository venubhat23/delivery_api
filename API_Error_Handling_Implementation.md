# API Error Handling Implementation

## Overview
This document explains the comprehensive JSON error handling implementation for all API endpoints in the delivery application. The implementation ensures that all API responses, including error responses, are returned in JSON format instead of HTML.

## Changes Made

### 1. Application Controller Updates
- Added global exception handlers using `rescue_from` for common exceptions
- Implemented consistent error response formatting
- Added proper logging for debugging

### 2. API Base Controller
- Created `Api::BaseController` that inherits from `ApplicationController`
- Added API-specific error handling methods
- Included helper methods for consistent response formatting
- Added support for structured error responses with timestamps

### 3. Controller Inheritance Updates
All API controllers now inherit from `Api::BaseController` instead of `ApplicationController`:
- `AuthenticationController`
- `CategoriesController`
- `CustomersController`
- `DeliveriesController`
- `DeliveryAssignmentsController`
- `DeliveryItemsController`
- `DeliverySchedulesController`
- `OrdersController`
- `ProductsController`
- `SubscriptionsController`

### 4. Custom Error Handling Middleware
- Created `ApiErrorMiddleware` to catch any remaining HTML responses
- Converts HTML error responses to JSON for API requests
- Handles unhandled exceptions as a last resort

### 5. Application Configuration
- Updated `config/application.rb` to include API-specific settings
- Added middleware configuration for error handling
- Configured CORS for API requests

### 6. Environment Configuration
- Updated production environment to handle API errors properly
- Set `debug_exception_response_format = :api` for production

### 7. Routes Configuration
- Added catch-all route for 404 errors in API namespace
- Ensures all unmatched API routes return JSON 404 responses

## Error Response Format

### Standard Error Response
```json
{
  "error": "Error message",
  "message": "Detailed error description",
  "type": "ExceptionType",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### Validation Error Response
```json
{
  "error": "Validation failed",
  "success": false,
  "errors": ["Field is required", "Email is invalid"],
  "field_errors": {
    "email": ["is invalid"],
    "name": ["can't be blank"]
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### Success Response Format
```json
{
  "success": true,
  "message": "Success",
  "data": {
    // Response data
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## Exception Handling

### Global Exception Handlers
The following exceptions are handled globally:

1. **StandardError**: Generic server errors
2. **ActiveRecord::RecordNotFound**: Resource not found (404)
3. **ActiveRecord::RecordInvalid**: Validation errors (422)
4. **ActiveRecord::RecordNotUnique**: Duplicate record conflicts (409)
5. **ActionController::ParameterMissing**: Missing required parameters (400)
6. **ActionController::UnpermittedParameters**: Invalid parameters (400)
7. **JWT::DecodeError**: Invalid authentication tokens (401)
8. **JSON::ParserError**: Invalid JSON format (400)
9. **ActionController::RoutingError**: Route not found (404)
10. **ActionController::UnknownFormat**: Unsupported format (406)

### HTTP Status Codes
- **200**: Success
- **400**: Bad Request (invalid parameters, JSON format)
- **401**: Unauthorized (authentication issues)
- **403**: Forbidden (authorization issues)
- **404**: Not Found (resource or endpoint not found)
- **406**: Not Acceptable (unsupported format)
- **409**: Conflict (duplicate records)
- **422**: Unprocessable Entity (validation errors)
- **500**: Internal Server Error (server errors)

## Helper Methods

### In Api::BaseController
- `render_success(data, message, status)`: Consistent success responses
- `render_error(message, status, details)`: Consistent error responses
- `render_validation_errors(model)`: Validation error responses
- `route_not_found`: Handle 404 errors for API routes

## Testing the Implementation

### Test 404 Error
```bash
curl -X GET http://localhost:3000/api/v1/nonexistent
```

Expected response:
```json
{
  "error": "Endpoint not found",
  "message": "The requested API endpoint does not exist",
  "path": "/api/v1/nonexistent",
  "method": "GET",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### Test Validation Error
```bash
curl -X POST http://localhost:3000/api/v1/categories \
  -H "Content-Type: application/json" \
  -d '{}'
```

Expected response:
```json
{
  "error": "Validation failed",
  "success": false,
  "errors": ["Name can't be blank"],
  "field_errors": {
    "name": ["can't be blank"]
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## Key Features

1. **Consistent Format**: All errors follow the same JSON structure
2. **Detailed Information**: Includes error type, message, and timestamp
3. **Environment Awareness**: Shows detailed errors in development, generic in production
4. **Proper Logging**: All errors are logged with full stack traces
5. **Middleware Fallback**: Catches any remaining HTML responses
6. **Route Handling**: Proper 404 handling for API routes
7. **Authentication Integration**: Seamless integration with JWT authentication

## Benefits

1. **API Consistency**: All responses are in JSON format
2. **Client-Friendly**: Easy to parse and handle in client applications
3. **Debugging**: Detailed error information in development
4. **Security**: Generic error messages in production
5. **Maintainability**: Centralized error handling logic
6. **Extensibility**: Easy to add new error types and handlers

This implementation ensures that all API endpoints return consistent JSON responses, improving the overall developer experience and making the API more reliable and predictable.