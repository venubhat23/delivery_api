# Vacation Management API Documentation

## Overview

The Vacation Management API allows customers to pause deliveries for a date range ("vacation"), with the ability to pause/unpause/cancel that vacation. The system ensures no deliveries occur during active vacations and that they resume cleanly when the vacation is lifted.

## Base URL
```
https://your-api-domain.com/api/v1
```

## Authentication
All requests require a valid JWT token in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

## Endpoints

### 1. Create Vacation
Create a new vacation for a customer.

**Endpoint:** `POST /vacations`

**Request Body:**
```json
{
  "start_date": "2025-08-20",
  "end_date": "2025-08-25",
  "reason": "Out of town",
  "mergeOverlaps": false
}
```

**Parameters:**
- `start_date` (required): ISO date format (YYYY-MM-DD)
- `end_date` (required): ISO date format (YYYY-MM-DD)
- `reason` (optional): Text description for the vacation
- `mergeOverlaps` (optional): Boolean, if true merges with overlapping vacations

**Success Response (201):**
```json
{
  "id": 42,
  "customer_id": 123,
  "start_date": "2025-08-20",
  "end_date": "2025-08-25",
  "status": "active",
  "reason": "Out of town",
  "affectedAssignmentsSkipped": 4
}
```

**Error Responses:**
- `400`: Invalid date format or validation errors
- `409`: Overlapping vacation exists (when mergeOverlaps=false)

### 2. List Vacations
Retrieve a paginated list of customer's vacations.

**Endpoint:** `GET /vacations`

**Query Parameters:**
- `status` (optional): Filter by status (active, paused, cancelled, completed)
- `from` (optional): Filter vacations overlapping with date range (ISO date)
- `to` (optional): Filter vacations overlapping with date range (ISO date)
- `page` (optional): Page number (default: 1)
- `per_page` (optional): Items per page (default: 20)

**Example:** `GET /vacations?status=active&page=1&per_page=10`

**Success Response (200):**
```json
{
  "vacations": [
    {
      "id": 42,
      "customer_id": 123,
      "start_date": "2025-08-20",
      "end_date": "2025-08-25",
      "status": "active",
      "reason": "Out of town",
      "affected_assignments_count": 4
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 10,
    "total_pages": 1,
    "total_count": 1
  }
}
```

### 3. Get Vacation Details
Retrieve details of a specific vacation.

**Endpoint:** `GET /vacations/{id}`

**Success Response (200):**
```json
{
  "id": 42,
  "customer_id": 123,
  "start_date": "2025-08-20",
  "end_date": "2025-08-25",
  "status": "active",
  "reason": "Out of town",
  "affected_assignments_count": 4
}
```

**Error Response:**
- `404`: Vacation not found

### 4. Pause Vacation
Temporarily pause an active vacation to resume deliveries.

**Endpoint:** `PATCH /vacations/{id}/pause`

**Headers:**
- `Idempotency-Key` (optional): Unique string to prevent duplicate operations

**Success Response (200):**
```json
{
  "id": 42,
  "customer_id": 123,
  "start_date": "2025-08-20",
  "end_date": "2025-08-25",
  "status": "paused",
  "reason": "Out of town",
  "paused_at": "2025-08-18T10:30:00Z",
  "affectedAssignmentsRecreated": 3
}
```

**Error Responses:**
- `404`: Vacation not found
- `422`: Vacation cannot be paused (wrong status or past dates)

### 5. Unpause Vacation
Resume a paused vacation to skip deliveries again.

**Endpoint:** `PATCH /vacations/{id}/unpause`

**Headers:**
- `Idempotency-Key` (optional): Unique string to prevent duplicate operations

**Success Response (200):**
```json
{
  "id": 42,
  "customer_id": 123,
  "start_date": "2025-08-20",
  "end_date": "2025-08-25",
  "status": "active",
  "reason": "Out of town",
  "unpaused_at": "2025-08-18T11:00:00Z",
  "affectedAssignmentsSkipped": 3
}
```

**Error Responses:**
- `404`: Vacation not found
- `422`: Vacation cannot be unpaused (wrong status or past dates)

### 6. Cancel Vacation
Cancel an active or paused vacation and reinstate all deliveries.

**Endpoint:** `DELETE /vacations/{id}`

**Headers:**
- `Idempotency-Key` (optional): Unique string to prevent duplicate operations

**Success Response (200):**
```json
{
  "message": "Vacation cancelled successfully",
  "affectedAssignmentsRecreated": 4
}
```

**Error Responses:**
- `404`: Vacation not found
- `422`: Vacation cannot be cancelled (wrong status or past dates)

### 7. Dry Run (Preview)
Preview the impact of creating a vacation without actually creating it.

**Endpoint:** `POST /vacations/dry_run`

**Request Body:**
```json
{
  "start_date": "2025-08-20",
  "end_date": "2025-08-25"
}
```

**Success Response (200):**
```json
{
  "assignmentsToSkip": 4,
  "assignmentsToRecreate": 0,
  "affectedDates": ["2025-08-20", "2025-08-21", "2025-08-22", "2025-08-23", "2025-08-24", "2025-08-25"],
  "preview": {
    "skipDetails": {
      "2025-08-20": 1,
      "2025-08-22": 1,
      "2025-08-24": 2
    },
    "recreateDetails": {}
  }
}
```

## Vacation States

- **active**: Vacation is currently blocking deliveries
- **paused**: Vacation is temporarily suspended, deliveries resume
- **cancelled**: Vacation has been cancelled, all deliveries restored
- **completed**: Vacation ended naturally (auto-set after end_date)

## Business Rules

### Date Validation
- `start_date` must be ≤ `end_date`
- Maximum vacation duration: 90 days (configurable)
- Cannot create vacations for past dates
- Same-day changes after cutoff (17:00) affect next day onward

### Overlap Rules
- By default, overlapping active/paused vacations are rejected
- Use `mergeOverlaps=true` to merge with existing vacations
- Only one active vacation per customer per date range

### Assignment Behavior
- **Active vacation**: Sets delivery assignments to `skipped_vacation` status
- **Paused vacation**: Restores assignments to `scheduled` status
- **Cancelled vacation**: Restores all affected assignments
- Past assignments are never modified

### Cutoff Time
- Daily cutoff at 17:00 (configurable via `VACATION_CUTOFF_TIME`)
- Changes after cutoff affect dates from next day onward
- Uses customer's timezone if available, otherwise system default

## Error Handling

### Common Error Responses

**400 Bad Request:**
```json
{
  "error": "Validation failed",
  "details": ["Start date can't be blank", "End date must be greater than start date"]
}
```

**401 Unauthorized:**
```json
{
  "error": "Unauthorized"
}
```

**403 Forbidden:**
```json
{
  "error": "Access denied"
}
```

**404 Not Found:**
```json
{
  "error": "Vacation not found"
}
```

**409 Conflict:**
```json
{
  "error": "Vacation dates overlap with an existing active or paused vacation",
  "conflicting_vacations": [
    {
      "id": 41,
      "start_date": "2025-08-18",
      "end_date": "2025-08-22",
      "status": "active"
    }
  ]
}
```

**422 Unprocessable Entity:**
```json
{
  "error": "Vacation cannot be paused"
}
```

## Idempotency

All mutation endpoints (POST, PATCH, DELETE) support idempotency via the `Idempotency-Key` header:

```http
Idempotency-Key: unique-operation-id-12345
```

Repeated requests with the same key return the cached response without side effects.

## Rate Limiting

- Mutation endpoints are rate-limited to prevent abuse
- Limits vary by endpoint and customer tier
- Rate limit headers included in responses

## Webhooks/Notifications (Optional)

The system can send notifications on vacation events:
- Vacation created
- Vacation paused/unpaused
- Vacation cancelled
- Vacation completed

Configure webhook URLs and notification preferences via customer settings.

## Examples

### Complete Workflow Example

1. **Create a vacation:**
```bash
curl -X POST https://api.example.com/api/v1/vacations \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "start_date": "2025-08-20",
    "end_date": "2025-08-25",
    "reason": "Summer vacation"
  }'
```

2. **Pause vacation temporarily:**
```bash
curl -X PATCH https://api.example.com/api/v1/vacations/42/pause \
  -H "Authorization: Bearer <token>" \
  -H "Idempotency-Key: pause-vacation-42-001"
```

3. **Resume vacation:**
```bash
curl -X PATCH https://api.example.com/api/v1/vacations/42/unpause \
  -H "Authorization: Bearer <token>" \
  -H "Idempotency-Key: unpause-vacation-42-001"
```

4. **Cancel vacation:**
```bash
curl -X DELETE https://api.example.com/api/v1/vacations/42 \
  -H "Authorization: Bearer <token>" \
  -H "Idempotency-Key: cancel-vacation-42-001"
```

## Configuration

### Environment Variables

- `VACATION_CUTOFF_TIME`: Daily cutoff time (default: "17:00")
- `MAX_VACATION_DURATION_DAYS`: Maximum vacation length in days (default: "90")
- `DEFAULT_TIMEZONE`: Default timezone for cutoff calculations (default: "UTC")

### Background Jobs

- **VacationCompletionJob**: Runs nightly to mark expired vacations as completed
- **AssignmentGeneratorJob**: Considers active vacations when generating assignments

## Database Schema

### user_vacations table
```sql
CREATE TABLE user_vacations (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status VARCHAR DEFAULT 'active' NOT NULL,
  reason TEXT,
  paused_at TIMESTAMP,
  unpaused_at TIMESTAMP,
  cancelled_at TIMESTAMP,
  created_by BIGINT,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

### delivery_assignments updates
```sql
ALTER TABLE delivery_assignments 
ADD COLUMN cancellation_reason TEXT;

-- New status values: 'scheduled', 'skipped_vacation', 'cancelled_user', 'delivered', 'failed'
```

## Testing

### Test Scenarios
1. Create vacation with valid date range
2. Create vacation with overlapping dates (should fail)
3. Create vacation with merge overlap option
4. Pause/unpause vacation operations
5. Cancel vacation and verify assignment restoration
6. Test cutoff time behavior
7. Test vacation auto-completion
8. Verify assignment generation skips vacation dates

### Sample Test Data
```json
{
  "customer_id": 123,
  "product_schedules": [
    {
      "product_id": 1,
      "frequency": "daily",
      "start_date": "2025-08-01"
    }
  ],
  "vacation_request": {
    "start_date": "2025-08-20",
    "end_date": "2025-08-25",
    "reason": "Test vacation"
  }
}
```