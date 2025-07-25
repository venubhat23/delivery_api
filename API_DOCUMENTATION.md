# Bank Details API

## GET /api/v1/bank_details

Returns the bank details and payment information for the business, including QR code for UPI payments.

### Authentication
Requires valid JWT token in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

### Request
```http
GET /api/v1/bank_details
Content-Type: application/json
Authorization: Bearer <jwt_token>
```

### Response

#### Success Response (200 OK)
```json
{
  "bank_details": {
    "business_name": "Atma Nirbhar Farm",
    "address": "123 Farm Road, Rural Area, Karnataka",
    "mobile": "+919876543210",
    "email": "admin@atmanirbharfarm.com",
    "gstin": "29AAAAA0000A1Z5",
    "pan_number": "AAAAA0000A",
    "account_holder_name": "Atma Nirbhar Farm",
    "bank_name": "Canara Bank",
    "account_number": "3194201000718",
    "ifsc_code": "CNRB0003194",
    "upi_id": "atmanirbharfarm@canara",
    "terms_and_conditions": [
      "Kindly make your monthly payment on or before the 10th of every month.",
      "Please share the payment screenshot immediately after completing the transaction to confirm your payment."
    ],
    "qr_code_url": "https://your-domain.com/qr_codes/upi_qr_1.svg"
  }
}
```

#### Error Response (404 Not Found)
```json
{
  "error": "Bank details not configured"
}
```

#### Error Response (401 Unauthorized)
```json
{
  "error": "Invalid or missing token"
}
```

### Features
- Returns complete business and banking information
- Automatically generates UPI QR code if UPI ID is provided
- QR code is saved as SVG format in `/public/qr_codes/` directory
- Returns full URL to access the QR code image
- Terms and conditions are formatted as an array of strings

### QR Code Generation
- QR codes are generated using the `rqrcode` gem
- Saved as SVG files for scalability
- Named with pattern: `upi_qr_{admin_setting_id}.svg`
- Accessible via the returned `qr_code_url`

### Usage Example

```javascript
// Example using fetch API
fetch('/api/v1/bank_details', {
  method: 'GET',
  headers: {
    'Authorization': 'Bearer ' + token,
    'Content-Type': 'application/json'
  }
})
.then(response => response.json())
.then(data => {
  console.log('Bank Details:', data.bank_details);
  if (data.bank_details.qr_code_url) {
    // Display QR code image
    document.getElementById('qr-image').src = data.bank_details.qr_code_url;
  }
});
```

### Notes
- Only one admin setting record is supported (uses `AdminSetting.first`)
- QR code is regenerated each time the endpoint is called if UPI ID exists
- All bank details are required fields except address, gstin, pan_number, and upi_id
- Email format and UPI ID format are validated at the model level