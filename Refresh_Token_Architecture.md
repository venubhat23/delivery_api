# Refresh Token Architecture and Usage

## Tokens
- Access Token (JWT): expires in 24 hours
- Refresh Token (DB-backed, hashed): expires in 30 days, rotated on each use

## Endpoints
- POST `/api/v1/login` → returns `token`, `refresh_token`
- POST `/api/v1/customer_login` → returns `token`, `refresh_token`
- POST `/api/v1/refresh_token` → request body: `{ "refresh_token": "<string>" }` → returns new `token`, rotated `refresh_token`
- POST `/api/v1/regenerate_token` → requires `Authorization: Bearer <token>`; reissues access token if current one is still valid

## When to call refresh API
1. On any 401 Unauthorized response due to expired access token
2. Proactively when `token_expires_in` is near zero (e.g., within 2–5 minutes)
3. Do not call refresh for every request; only on the above conditions

## Client Flow
1. Login/Customer Login:
   - Store `token` (in memory or short-term storage) and `refresh_token` (secure storage or httpOnly cookie).
2. Use `token` in `Authorization: Bearer <token>` for API calls.
3. If a request returns 401 (expired):
   - Call `POST /api/v1/refresh_token` with current `refresh_token`.
   - Replace stored `token` and `refresh_token` with the response.
   - Retry the original API call once.
4. If refresh fails (401/422):
   - Redirect user to login.

## Minimal Examples

### Login (admin/delivery)
Request:
```http
POST /api/v1/login
Content-Type: application/json

{ "phone": "+919876543210", "password": "password123", "role": "admin" }
```
Response (200):
```json
{ "token": "<jwt>", "refresh_token": "<refresh>", "token_expires_in": 86400 }
```

### Customer Login
Request:
```http
POST /api/v1/customer_login
Content-Type: application/json

{ "phone": "+919876543220", "password": "password123" }
```
Response (200):
```json
{ "token": "<jwt>", "refresh_token": "<refresh>", "token_expires_in": 86400 }
```

### Refresh Token
Request:
```http
POST /api/v1/refresh_token
Content-Type: application/json

{ "refresh_token": "<refresh>" }
```
Response (200):
```json
{ "token": "<new jwt>", "refresh_token": "<rotated refresh>", "token_expires_in": 86400 }
```

## Notes
- Refresh tokens are stored hashed in DB and rotated on use; old token is revoked.
- Access tokens remain 24h; refresh tokens default to 30 days (configurable in code).
- To revoke sessions on logout, delete/revoke the user’s refresh token records.