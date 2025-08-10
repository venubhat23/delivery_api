### API: New Endpoints (v1)

All endpoints require Authorization: Bearer <token> obtained from login/signup.

- Base URL: /api/v1

---

### GET /advertisements
- Purpose: List active advertisements currently within their date range
- Response 200:
```json
[
  {"id":1,"name":"Festive Offer","image_url":"https://...","start_date":"2025-08-01","end_date":"2025-08-31","status":"active"}
]
```

---

### GET /invoices
- Purpose: Show invoices for the logged-in customer
- Admin/Delivery Person: optional filter by customer_id
- Query params: customer_id (admin/delivery_person only)
- Response 200:
```json
{
  "count": 2,
  "total_amount": 450.0,
  "invoices": [ { /* invoice with items and customer included */ } ]
}
```

---

### GET /settings
- Purpose: App settings and user preferences
- Response 200:
```json
{
  "faq": [ {"q":"...","a":"..."} ],
  "contact_us": {"business_name":"...","mobile":"...","email":"...","address":"...","upi_qr_code":"/...svg"},
  "refer_and_earn": {"referral_code":"ABCD1234","message":"Share this code to earn rewards"},
  "delivery_preferences": {"preferred_language":"en","delivery_time_preference":"morning","notification_method":"sms"},
  "terms_and_conditions": "...",
  "privacy_policy": "..."
}
```

---

### Vacations

#### POST /vacations
- Body:
```json
{ "vacation": { "start_date": "2025-08-12", "end_date": "2025-08-15", "notes": "Out of town" } }
```
- Behavior: Creates vacation for logged-in customer and deletes pending DeliveryAssignments in range
- Response 201:
```json
{ "message": "Vacation created", "vacation": {"id":1,"start_date":"2025-08-12","end_date":"2025-08-15","notes":"Out of town"} }
```

#### GET /vacations
- Response 200: Array of vacations for the logged-in customer

---

### POST /refresh
- Purpose: Return refreshed data for customers and delivery personnel
- Response 200:
```json
{
  "customers": [ {"id":1,"name":"..."} ],
  "delivery_personnel": [ {"id":7,"name":"...","phone":"..."} ],
  "refreshed_at": "2025-08-10T09:20:00Z"
}
```