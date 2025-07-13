# Regenerate Token API Documentation

## Overview

The Regenerate Token API allows authenticated users to regenerate their JWT tokens. This is useful when tokens are about to expire or have been compromised. The API supports all user roles in the system: customer, admin, and delivery_person.

## Implementation Summary

### Files Modified/Created

1. **`app/controllers/api/v1/authentication_controller.rb`** - Added `regenerate_token` method
2. **`config/routes.rb`** - Added route for regenerate token endpoint
3. **`Complete_API_Collection.json`** - Updated with regenerate token endpoint
4. **`Regenerate_Token_API_Collection.json`** - New standalone Postman collection

### API Endpoint

```
POST /api/v1/regenerate_token
```

### Authentication Required

- **Headers**: `Authorization: Bearer <jwt_token>`
- **Method**: POST
- **Body**: Empty (no body required)

## API Behavior

### For Customer Role

**Request:**
```bash
curl -X POST http://localhost:3000/api/v1/regenerate_token \
  -H "Authorization: Bearer <customer_jwt_token>" \
  -H "Content-Type: application/json"
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoyLCJjdXN0b21lcl9pZCI6MSwiZXhwIjoxNzA2MjYwODAwfQ.new_token_here",
  "user": {
    "id": 2,
    "name": "John Customer",
    "role": "customer",
    "email": "customer@example.com",
    "phone": "+919876543210"
  },
  "customer": {
    "id": 1,
    "name": "John Customer",
    "address": "123 Main Street",
    "phone_number": "+919876543210",
    "email": "customer@example.com",
    "preferred_language": "en",
    "delivery_time_preference": "morning",
    "notification_method": "sms"
  },
  "message": "Token regenerated successfully"
}
```

### For Admin/Delivery Person Role

**Request:**
```bash
curl -X POST http://localhost:3000/api/v1/regenerate_token \
  -H "Authorization: Bearer <admin_or_delivery_jwt_token>" \
  -H "Content-Type: application/json"
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE3MDYyNjA4MDB9.new_admin_token_here",
  "user": {
    "id": 1,
    "name": "Admin User",
    "role": "admin",
    "email": "admin@example.com",
    "phone": "+919876543200"
  },
  "message": "Token regenerated successfully"
}
```

## Error Handling

### 1. No Authentication Token

**Request:**
```bash
curl -X POST http://localhost:3000/api/v1/regenerate_token \
  -H "Content-Type: application/json"
```

**Response:**
```json
{
  "error": "Authentication required"
}
```
**Status Code:** 401 Unauthorized

### 2. Invalid Token

**Request:**
```bash
curl -X POST http://localhost:3000/api/v1/regenerate_token \
  -H "Authorization: Bearer invalid_token" \
  -H "Content-Type: application/json"
```

**Response:**
```json
{
  "errors": "Invalid token"
}
```
**Status Code:** 401 Unauthorized

### 3. Customer Record Not Found

For customers where the user exists but the customer record is missing:

**Response:**
```json
{
  "error": "Customer record not found"
}
```
**Status Code:** 422 Unprocessable Entity

## Token Structure

### Customer Token Payload
```json
{
  "user_id": 2,
  "customer_id": 1,
  "exp": 1706260800
}
```

### Admin/Delivery Person Token Payload
```json
{
  "user_id": 1,
  "exp": 1706260800
}
```

## Usage Examples

### JavaScript/Frontend Integration

```javascript
// Function to regenerate token
async function regenerateToken() {
  try {
    const response = await fetch('/api/v1/regenerate_token', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('jwt_token')}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (response.ok) {
      const data = await response.json();
      // Update stored token
      localStorage.setItem('jwt_token', data.token);
      console.log('Token regenerated successfully');
      return data;
    } else {
      throw new Error('Token regeneration failed');
    }
  } catch (error) {
    console.error('Error regenerating token:', error);
    throw error;
  }
}

// Usage with automatic token refresh
async function makeAuthenticatedRequest(url, options = {}) {
  try {
    const response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${localStorage.getItem('jwt_token')}`
      }
    });
    
    if (response.status === 401) {
      // Token might be expired, try to regenerate
      await regenerateToken();
      // Retry the original request
      return fetch(url, {
        ...options,
        headers: {
          ...options.headers,
          'Authorization': `Bearer ${localStorage.getItem('jwt_token')}`
        }
      });
    }
    
    return response;
  } catch (error) {
    console.error('Request failed:', error);
    throw error;
  }
}
```

### Mobile App Integration (React Native)

```javascript
import AsyncStorage from '@react-native-async-storage/async-storage';

class TokenService {
  static async regenerateToken() {
    try {
      const currentToken = await AsyncStorage.getItem('jwt_token');
      
      const response = await fetch('http://your-api-url/api/v1/regenerate_token', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${currentToken}`,
          'Content-Type': 'application/json'
        }
      });
      
      const data = await response.json();
      
      if (response.ok) {
        await AsyncStorage.setItem('jwt_token', data.token);
        return data;
      } else {
        throw new Error(data.error || 'Token regeneration failed');
      }
    } catch (error) {
      console.error('Token regeneration error:', error);
      throw error;
    }
  }
}
```

## Postman Collection Usage

### 1. Import the Collection

Import `Regenerate_Token_API_Collection.json` into Postman.

### 2. Set Environment Variables

- `base_url`: Your API base URL (default: `http://localhost:3000`)
- `customer_token`: JWT token for customer user
- `admin_token`: JWT token for admin user
- `delivery_person_token`: JWT token for delivery person user

### 3. Get Initial Tokens

Use the "🔐 Authentication Setup" folder to login and get initial tokens:

1. **Customer Login** - Get customer token
2. **Admin Login** - Get admin token
3. **Delivery Person Login** - Get delivery person token

### 4. Test Token Regeneration

Use the "🔄 Token Regeneration" folder to test the API:

1. **Regenerate Token - Customer**
2. **Regenerate Token - Admin**
3. **Regenerate Token - Delivery Person**

### 5. Test Error Scenarios

Use the "⚠️ Error Scenarios" folder to test error handling:

1. **Unauthorized - No Token**
2. **Unauthorized - Invalid Token**

## Security Considerations

1. **Token Expiration**: The regenerated token has the same expiration time as regular tokens (24 hours by default)
2. **Authentication Required**: The endpoint requires a valid JWT token
3. **Role-Based Response**: The API returns different data based on user role
4. **No Token Revocation**: The old token is not invalidated (this is normal JWT behavior)

## Integration Best Practices

1. **Automatic Token Refresh**: Implement automatic token refresh when receiving 401 responses
2. **Token Storage**: Store tokens securely (localStorage for web, secure storage for mobile)
3. **Error Handling**: Properly handle different error scenarios
4. **Token Validation**: Always validate tokens before making requests
5. **Logout Handling**: Clear stored tokens on logout

## Testing

### Unit Tests

```ruby
# spec/controllers/api/v1/authentication_controller_spec.rb

describe 'POST #regenerate_token' do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  
  before do
    request.headers['Authorization'] = "Bearer #{token}"
  end
  
  it 'regenerates token successfully' do
    post :regenerate_token
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)['token']).to be_present
  end
  
  it 'returns error without token' do
    request.headers['Authorization'] = nil
    post :regenerate_token
    expect(response).to have_http_status(:unauthorized)
  end
end
```

### Integration Tests

```ruby
# spec/requests/api/v1/regenerate_token_spec.rb

describe 'POST /api/v1/regenerate_token' do
  let(:customer_user) { create(:user, role: 'customer') }
  let(:customer) { create(:customer, user: customer_user) }
  let(:token) { JsonWebToken.encode(user_id: customer_user.id, customer_id: customer.id) }
  
  it 'regenerates customer token' do
    post '/api/v1/regenerate_token', 
      headers: { 'Authorization' => "Bearer #{token}" }
    
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('token')
    expect(response.body).to include('customer')
  end
end
```

## Troubleshooting

### Common Issues

1. **401 Unauthorized**
   - Check if Authorization header is present
   - Verify token format: `Bearer <token>`
   - Ensure token is not expired

2. **422 Unprocessable Entity**
   - Customer record missing for customer role users
   - Database integrity issues

3. **Server Error**
   - Check Rails logs for detailed error messages
   - Verify database connection
   - Ensure all dependencies are properly installed

### Debug Commands

```bash
# Check Rails logs
tail -f log/development.log

# Test token validity
rails console
> token = "your_token_here"
> JsonWebToken.decode(token)

# Check user and customer records
rails console
> User.find(user_id)
> Customer.find_by(user_id: user_id)
```

## Conclusion

The Regenerate Token API provides a secure way for authenticated users to refresh their JWT tokens. It's designed to work seamlessly with the existing authentication system and supports all user roles. The comprehensive Postman collection makes it easy to test and integrate with your applications.

For any issues or questions, please refer to the troubleshooting section or check the Rails application logs for detailed error information.