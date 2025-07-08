# Analytics API Documentation

## Overview
The Analytics API provides comprehensive social media analytics functionality similar to Instagram's analytics dashboard. It includes metrics tracking, user analytics management, and a beautiful dashboard interface.

## Base URL
```
/api/v1
```

## Endpoints

### 1. Get All Analytics
**GET** `/analytics`

Returns all analytics records in the system.

**Response:**
```json
[
  {
    "id": 1,
    "user_id": 1,
    "total_likes": 1250,
    "total_comments": 350,
    "total_shares": 125,
    "total_saves": 890,
    "total_clicks": 2100,
    "total_reach": 15000,
    "profile_visits": 450,
    "followers_count": 5200,
    "following_count": 180,
    "media_count": 45,
    "reach_potential": 8500,
    "earned_media": 25,
    "total_engagement": 24.04,
    "engagement_rate": 0.53,
    "average_interactions": 57.0,
    "created_at": "2025-01-06T12:00:00.000Z",
    "updated_at": "2025-01-06T12:00:00.000Z"
  }
]
```

### 2. Get Specific Analytics
**GET** `/analytics/:id`

Returns analytics for a specific analytics record.

**Parameters:**
- `id` (required): Analytics record ID

**Response:**
```json
{
  "id": 1,
  "user_id": 1,
  "total_likes": 1250,
  "total_comments": 350,
  "total_shares": 125,
  "total_saves": 890,
  "total_clicks": 2100,
  "total_reach": 15000,
  "profile_visits": 450,
  "followers_count": 5200,
  "following_count": 180,
  "media_count": 45,
  "reach_potential": 8500,
  "earned_media": 25,
  "total_engagement": 24.04,
  "engagement_rate": 0.53,
  "average_interactions": 57.0,
  "created_at": "2025-01-06T12:00:00.000Z",
  "updated_at": "2025-01-06T12:00:00.000Z"
}
```

### 3. Get User Analytics Dashboard
**GET** `/users/:user_id/analytics`

Returns complete analytics dashboard data for a specific user, including user profile and analytics metrics.

**Parameters:**
- `user_id` (required): User ID

**Response:**
```json
{
  "user": {
    "id": 1,
    "name": "Akshar Shetty",
    "email": "akshar@example.com",
    "username": "@aksharshetty1",
    "avatar_url": "/assets/default-avatar.png"
  },
  "analytics": {
    "id": 1,
    "user_id": 1,
    "total_likes": 0,
    "total_comments": 0,
    "total_shares": 0,
    "total_saves": 15,
    "total_clicks": 25,
    "total_reach": 1,
    "profile_visits": 0,
    "followers_count": 1,
    "following_count": 21,
    "media_count": 1,
    "reach_potential": 0,
    "earned_media": 0,
    "total_engagement": 0.0,
    "engagement_rate": 0.0,
    "average_interactions": 0,
    "created_at": "2025-01-06T12:00:00.000Z",
    "updated_at": "2025-01-06T12:00:00.000Z"
  },
  "recent_posts": []
}
```

### 4. Create Analytics
**POST** `/analytics`

Creates new analytics record for a user.

**Request Body:**
```json
{
  "analytics": {
    "total_likes": 100,
    "total_comments": 25,
    "total_shares": 10,
    "total_saves": 50,
    "total_clicks": 200,
    "total_reach": 1000,
    "profile_visits": 75,
    "followers_count": 500,
    "following_count": 150,
    "media_count": 10,
    "reach_potential": 800,
    "earned_media": 5
  },
  "user_id": 1
}
```

**Response:**
```json
{
  "id": 2,
  "user_id": 1,
  "total_likes": 100,
  "total_comments": 25,
  "total_shares": 10,
  "total_saves": 50,
  "total_clicks": 200,
  "total_reach": 1000,
  "profile_visits": 75,
  "followers_count": 500,
  "following_count": 150,
  "media_count": 10,
  "reach_potential": 800,
  "earned_media": 5,
  "total_engagement": 37.0,
  "engagement_rate": 3.7,
  "average_interactions": 18.5,
  "created_at": "2025-01-06T12:00:00.000Z",
  "updated_at": "2025-01-06T12:00:00.000Z"
}
```

### 5. Update Analytics
**PUT/PATCH** `/analytics/:id`

Updates an existing analytics record.

**Parameters:**
- `id` (required): Analytics record ID

**Request Body:**
```json
{
  "analytics": {
    "total_likes": 150,
    "total_comments": 30,
    "followers_count": 520
  }
}
```

**Response:**
```json
{
  "id": 1,
  "user_id": 1,
  "total_likes": 150,
  "total_comments": 30,
  "total_shares": 10,
  "total_saves": 50,
  "total_clicks": 200,
  "total_reach": 1000,
  "profile_visits": 75,
  "followers_count": 520,
  "following_count": 150,
  "media_count": 10,
  "reach_potential": 800,
  "earned_media": 5,
  "total_engagement": 44.23,
  "engagement_rate": 4.42,
  "average_interactions": 23.0,
  "created_at": "2025-01-06T12:00:00.000Z",
  "updated_at": "2025-01-06T12:00:00.000Z"
}
```

### 6. Delete Analytics
**DELETE** `/analytics/:id`

Deletes an analytics record.

**Parameters:**
- `id` (required): Analytics record ID

**Response:**
- Status: 204 No Content

### 7. Generate Sample Analytics
**POST** `/analytics/generate_sample`

Generates sample analytics data for a user (useful for testing).

**Request Body:**
```json
{
  "user_id": 1
}
```

**Response:**
```json
{
  "id": 3,
  "user_id": 1,
  "total_likes": 456,
  "total_comments": 123,
  "total_shares": 78,
  "total_saves": 234,
  "total_clicks": 567,
  "total_reach": 3456,
  "profile_visits": 89,
  "followers_count": 2345,
  "following_count": 234,
  "media_count": 23,
  "reach_potential": 1234,
  "earned_media": 12,
  "total_engagement": 38.12,
  "engagement_rate": 3.81,
  "average_interactions": 38.8,
  "created_at": "2025-01-06T12:00:00.000Z",
  "updated_at": "2025-01-06T12:00:00.000Z"
}
```

## Calculated Fields

The API automatically calculates and returns the following derived metrics:

### Total Engagement Percentage
```
((total_likes + total_comments + total_shares + total_saves) / followers_count) * 100
```

### Engagement Rate
```
((total_likes + total_comments + total_shares + total_saves) / (media_count * followers_count)) * 100
```

### Average Interactions
```
(total_likes + total_comments + total_shares + total_saves) / media_count
```

## Analytics Dashboard UI

### Accessing the Dashboard
Visit: `http://localhost:3000/analytics_dashboard.html`

### Features
- **User Selection**: Dropdown to select different users
- **Real-time Metrics**: Live display of all analytics metrics
- **Responsive Design**: Works on desktop, tablet, and mobile
- **Purple Theme**: Matches Instagram analytics color scheme
- **Interactive Cards**: Hover effects and smooth animations
- **Auto-refresh**: Button to refresh data
- **Sample Data Generation**: Automatically creates sample data if none exists

### Dashboard Sections

1. **Profile Section**
   - User avatar and information
   - Followers/Following counts
   - Engagement rate, earned media, average interactions

2. **Analytics Grid**
   - 12 metric cards displaying all key analytics
   - Color-coded cards for different metric types
   - Hover animations and effects

3. **Recent Posts**
   - Section for displaying recent Instagram posts
   - Currently shows empty state with placeholder

## Error Handling

### Error Response Format
```json
{
  "errors": {
    "field_name": ["error message"]
  }
}
```

### Common Error Codes
- `400 Bad Request`: Invalid request parameters
- `404 Not Found`: Analytics record or user not found
- `422 Unprocessable Entity`: Validation errors
- `500 Internal Server Error`: Server error

## Authentication
Currently, the API doesn't require authentication. In a production environment, you should implement proper authentication and authorization.

## Rate Limiting
No rate limiting is currently implemented. Consider adding rate limiting for production use.

## Sample Data
The system includes seed data with analytics for:
- Akshar Shetty (matching the original design)
- Admin User (high engagement metrics)
- Delivery Person (moderate engagement metrics)

To seed the database:
```bash
rails db:seed
```

## Frontend Integration

### JavaScript Example
```javascript
// Fetch analytics dashboard data
async function getAnalyticsDashboard(userId) {
    const response = await fetch(`/api/v1/users/${userId}/analytics`);
    const data = await response.json();
    return data;
}

// Generate sample analytics
async function generateSampleAnalytics(userId) {
    const response = await fetch('/api/v1/analytics/generate_sample', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ user_id: userId })
    });
    return response.json();
}
```

### cURL Examples

```bash
# Get user analytics dashboard
curl -X GET http://localhost:3000/api/v1/users/1/analytics

# Generate sample analytics
curl -X POST http://localhost:3000/api/v1/analytics/generate_sample \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1}'

# Update analytics
curl -X PUT http://localhost:3000/api/v1/analytics/1 \
  -H "Content-Type: application/json" \
  -d '{"analytics": {"total_likes": 200}}'
```

## Next Steps

1. **Authentication**: Implement user authentication and authorization
2. **Real-time Updates**: Add WebSocket support for real-time analytics updates
3. **Data Visualization**: Add charts and graphs for trend analysis
4. **Export Features**: Add CSV/PDF export functionality
5. **Post Management**: Implement actual post data and recent posts functionality
6. **Advanced Metrics**: Add more sophisticated analytics calculations
7. **Notifications**: Add alerts for significant metric changes