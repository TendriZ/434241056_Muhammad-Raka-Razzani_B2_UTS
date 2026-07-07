# E-Ticketing Helpdesk - API Testing Guide with cURL

**Base URL:** `https://cvmzoczzdqpiucpedghp.supabase.co`

**Anon Key:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc`

---

## Prerequisites

```bash
# Set environment variables (optional)
export SUPABASE_URL="https://cvmzoczzdqpiucpedghp.supabase.co"
export SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc"
export ACCESS_TOKEN="<your_jwt_token_after_login>"
```

---

## 1. AUTHENTICATION ENDPOINTS

### 1.1 Register (FR-003)

```bash
curl -X POST 'https://cvmzoczzdqpiucpedghp.supabase.co/auth/v1/signup' \
  -H 'Content-Type: application/json' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc' \
  -d '{
    "email": "mahasiswa123@helpdesk.com",
    "password": "password123",
    "options": {
      "data": {
        "name": "Budi Santoso",
        "username": "mahasiswa123",
        "role": "user"
      }
    }
  }'
```

**Response:**
```json
{
  "id": "uuid-of-new-user",
  "email": "mahasiswa123@helpdesk.com",
  "user": null
}
```

---

### 1.2 Login (FR-001)

```bash
curl -X POST 'https://cvmzoczzdqpiucpedghp.supabase.co/auth/v1/token?grant_type=password' \
  -H 'Content-Type: application/json' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc' \
  -d '{
    "email": "mahasiswa123@helpdesk.com",
    "password": "password123"
  }'
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "...",
  "user": {
    "id": "uuid-of-user",
    "email": "mahasiswa123@helpdesk.com",
    "user_metadata": null
  }
}
```

**Copy the `access_token` for subsequent requests!**

---

### 1.3 Get Current User

```bash
curl -X GET 'https://cvmzoczzdqpiucpedghp.supabase.co/auth/v1/user' \
  -H 'Authorization: Bearer <your_access_token>' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc'
```

---

### 1.4 Logout (FR-002)

```bash
curl -X POST 'https://cvmzoczzdqpiucpedghp.supabase.co/auth/v1/logout' \
  -H 'Authorization: Bearer <your_access_token>' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc'
```

---

### 1.5 Reset Password (FR-004)

```bash
# Request reset password email
curl -X POST 'https://cvmzoczzdqpiucpedghp.supabase.co/auth/v1/recover' \
  -H 'Content-Type: application/json' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc' \
  -d '{
    "email": "mahasiswa123@helpdesk.com"
  }'
```

---

## 2. TICKET ENDPOINTS

### 2.1 Create Ticket (FR-005)

```bash
curl -X POST 'https://cvmzoczzdqpiucpedghp.supabase.co/rest/v1/tickets' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <your_access_token>' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc' \
  -H 'Prefer: return=representation' \
  -d '{
    "user_id": "<your_user_id>",
    "title": "Tidak bisa login ke sistem",
    "description": "Saya sudah mencoba beberapa kali tetapi tidak bisa masuk ke sistem akademik",
    "status": "pending",
    "category": "technical",
    "priority": "high"
  }'
```

**Response:**
```json
[
  {
    "id": "ticket-uuid",
    "user_id": "your-user-id",
    "title": "Tidak bisa login ke sistem",
    "description": "Saya sudah mencoba beberapa kali...",
    "status": "pending",
    "category": "technical",
    "priority": "high",
    "assigned_to": null,
    "created_at": "2026-01-15T10:30:00.000Z",
    "updated_at": null
  }
]
```

---

### 2.2 Get All Tickets (FR-006)

```bash
# Get all tickets (Admin & Helpdesk only)
curl -X GET 'https://cvmzoczzdqpiucpedghp.supabase.co/rest/v1/tickets?order=created_at.desc' \
  -H 'Authorization: Bearer <your_access_token>' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc'

# Get only own tickets (User)
curl -X GET 'https://cvmzoczzdqpiucpedghp.supabase.co/rest/v1/tickets?user_id=eq.<your_user_id>&order=created_at.desc' \
  -H 'Authorization: Bearer <your_access_token>' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc'

# Filter by status
curl -X GET 'https://cvmzoczzdqpiucpedghp.supabase.co/rest/v1/tickets?status=eq.pending&order=created_at.desc' \
  -H 'Authorization: Bearer <your_access_token>' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc'
```

---

### 2.3 Get Ticket Detail (FR-006.3)

```bash
curl -X GET 'https://cvmzoczzdqpiucpedghp.supabase.co/rest/v1/tickets?id=eq.<ticket_uuid>&select=*' \
  -H 'Authorization: Bearer <your_access_token>' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc'
```

---

### 2.4 Assign Ticket (FR-007 / FR-006.4)

```bash
# Admin assigns ticket to helpdesk (status automatically changes to on_progress)
curl -X PATCH 'https://cvmzoczzdqpiucpedghp.supabase.co/rest/v1/tickets?id=eq.<ticket_uuid>' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <your_access_token>' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc' \
  -H 'Prefer: return=representation' \
  -d '{
    "assigned_to": "<helpdesk_user_id>",
    "status": "on_progress",
    "updated_at": "2026-01-15T11:00:00.000Z"
  }'
```

---

### 2.5 Finish Ticket (Helpdesk) - FR-006

```bash
# Helpdesk finishes ticket (status changes to resolved)
curl -X PATCH 'https://cvmzoczzdqpiucpedghp.supabase.co/rest/v1/tickets?id=eq.<ticket_uuid>' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <your_access_token>' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc' \
  -H 'Prefer: return=representation' \
  -d '{
    "status": "resolved",
    "updated_at": "2026-01-15T14:30:00.000Z"
  }'
```

---

### 2.6 Delete Ticket (Admin Only) - FR-007

```bash
curl -X DELETE 'https://cvmzoczzdqpiucpedghp.supabase.co/rest/v1/tickets?id=eq.<ticket_uuid>' \
  -H 'Authorization: Bearer <your_access_token>' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc'
```

---

## 3. TICKET HISTORY ENDPOINTS

### 3.1 Get Ticket History (FR-010)

```bash
curl -X GET 'https://cvmzoczzdqpiucpedghp.supabase.co/rest/v1/ticket_history?ticket_id=eq.<ticket_uuid>&order=created_at.desc' \
  -H 'Authorization: Bearer <your_access_token>' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc'
```

---

### 3.2 Add Comment (FR-007)

```bash
curl -X POST 'https://cvmzoczzdqpiucpedghp.supabase.co/rest/v1/ticket_history' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <your_access_token>' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc' \
  -H 'Prefer: return=representation' \
  -d '{
    "ticket_id": "<ticket_uuid>",
    "user_id": "<your_user_id>",
    "action": "Komentar",
    "message": "Mohon info lebih lanjut tentang masalah ini"
  }'
```

---

## 4. PROFILE ENDPOINTS

### 4.1 Get User Profile

```bash
curl -X GET 'https://cvmzoczzdqpiucpedghp.supabase.co/rest/v1/profiles?id=eq.<your_user_id>&select=*' \
  -H 'Authorization: Bearer <your_access_token>' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc'
```

---

### 4.2 Get All Helpdesk Users (for Assign Ticket)

```bash
curl -X GET 'https://cvmzoczzdqpiucpedghp.supabase.co/rest/v1/profiles?role=eq.helpdesk&select=*' \
  -H 'Authorization: Bearer <your_access_token>' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc'
```

---

### 4.3 Get All Users (Admin User Management)

```bash
curl -X GET 'https://cvmzoczzdqpiucpedghp.supabase.co/rest/v1/profiles?select=*' \
  -H 'Authorization: Bearer <your_access_token>' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc'
```

---

## 5. STATISTICS ENDPOINTS (FR-009)

### 5.1 Get Ticket Statistics

```bash
# Count tickets by status
curl -X GET 'https://cvmzoczzdqpiucpedghp.supabase.co/rest/v1/tickets?select=status' \
  -H 'Authorization: Bearer <your_access_token>' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc' \
  | jq 'group_by(.status) | map({status: .[0].status, count: length})'
```

---

## 6. COMPLETE TESTING SCENARIO

### Scenario 1: Full Ticket Flow

```bash
#!/bin/bash
# complete-ticket-flow-test.sh

# Configuration
SUPABASE_URL="https://cvmzoczzdqpiucpedghp.supabase.co"
ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc"

echo "=== E-Ticketing Helpdesk API Test ==="
echo ""

# Step 1: Register as User
echo "[1] Registering new user..."
REGISTER_RESPONSE=$(curl -s -X POST "$SUPABASE_URL/auth/v1/signup" \
  -H "Content-Type: application/json" \
  -H "apikey: $ANON_KEY" \
  -d '{
    "email": "testuser999@helpdesk.com",
    "password": "Test123!",
    "options": {
      "data": {
        "name": "Test User",
        "username": "testuser999",
        "role": "user"
      }
    }
  }')

USER_ID=$(echo $REGISTER_RESPONSE | jq -r '.id')
echo "User registered: $USER_ID"
echo ""

# Step 2: Login
echo "[2] Logging in..."
LOGIN_RESPONSE=$(curl -s -X POST "$SUPABASE_URL/auth/v1/token?grant_type=password" \
  -H "Content-Type: application/json" \
  -H "apikey: $ANON_KEY" \
  -d '{
    "email": "testuser999@helpdesk.com",
    "password": "Test123!"
  }')

ACCESS_TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.access_token')
echo "Access token obtained"
echo ""

# Step 3: Create ticket
echo "[3] Creating ticket..."
TICKET_RESPONSE=$(curl -s -X POST "$SUPABASE_URL/rest/v1/tickets" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "apikey: $ANON_KEY" \
  -H "Prefer: return=representation" \
  -d '{
    "user_id": "'$USER_ID'",
    "title": "Test ticket from API",
    "description": "This is a test ticket created via cURL",
    "status": "pending",
    "category": "technical",
    "priority": "normal"
  }')

TICKET_ID=$(echo $TICKET_RESPONSE | jq -r '.[0].id')
echo "Ticket created: $TICKET_ID"
echo ""

# Step 4: Get all tickets
echo "[4] Getting all my tickets..."
curl -s -X GET "$SUPABASE_URL/rest/v1/tickets?user_id=eq.$USER_ID&order=created_at.desc" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "apikey: $ANON_KEY" | jq '.'
echo ""

# Step 5: Get ticket detail
echo "[5] Getting ticket detail..."
curl -s -X GET "$SUPABASE_URL/rest/v1/tickets?id=eq.$TICKET_ID&select=*" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "apikey: $ANON_KEY" | jq '.'
echo ""

# Step 6: Add comment
echo "[6] Adding comment..."
curl -s -X POST "$SUPABASE_URL/rest/v1/ticket_history" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "apikey: $ANON_KEY" \
  -H "Prefer: return=representation" \
  -d '{
    "ticket_id": "'$TICKET_ID'",
    "user_id": "'$USER_ID'",
    "action": "Komentar",
    "message": "Test comment via API"
  }' | jq '.'
echo ""

# Step 7: Get ticket history
echo "[7] Getting ticket history..."
curl -s -X GET "$SUPABASE_URL/rest/v1/ticket_history?ticket_id=eq.$TICKET_ID&order=created_at.desc" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "apikey: $ANON_KEY" | jq '.'
echo ""

echo "=== Test Complete ==="
```

---

## 7. EXPECTED RESPONSE CODES

| Code | Meaning |
|------|---------|
| `200 OK` | Request successful |
| `201 Created` | Resource created successfully |
| `204 No Content` | Delete successful |
| `400 Bad Request` | Invalid request body |
| `401 Unauthorized` | Missing/invalid access token |
| `403 Forbidden` | Insufficient permissions (RLS) |
| `404 Not Found` | Resource not found |
| `500 Internal Server Error` | Server error |

---

## 8. COMMON ERRORS & SOLUTIONS

### Error: "Invalid JWT"

```bash
# Token expired, login again to get new access token
curl -X POST 'https://cvmzoczzdqpiucpedghp.supabase.co/auth/v1/token?grant_type=password' \
  -H 'Content-Type: application/json' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc' \
  -d '{"email": "your@email", "password": "yourpassword"}'
```

### Error: "Insufficient permissions"

```bash
# Check your user's role in profiles table
curl -X GET 'https://cvmzoczzdqpiucpedghp.supabase.co/rest/v1/profiles?id=eq.<your_user_id>&select=role' \
  -H 'Authorization: Bearer <your_access_token>' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc'
```

---

## 9. QUICK REFERENCE

```bash
# Base URL
BASE_URL="https://cvmzoczzdqpiucpedghp.supabase.co"

# Headers
HEADERS='
  -H "Content-Type: application/json"
  -H "Authorization: Bearer <ACCESS_TOKEN>"
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc"
'

# Endpoints
AUTH="$BASE_URL/auth/v1"
TICKETS="$BASE_URL/rest/v1/tickets"
HISTORY="$BASE_URL/rest/v1/ticket_history"
PROFILES="$BASE_URL/rest/v1/profiles"
```

---

*Generated for E-Ticketing Helpdesk Mobile Application*
*Universitas Airlangga - 2026*
