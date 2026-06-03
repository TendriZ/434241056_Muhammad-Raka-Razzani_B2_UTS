# API E-Ticketing Helpdesk
## Ringkasan untuk Tugas Mobile Praktikum

---

### Identitas Mahasiswa
- **Nama**: Muhammad Raka Razzani
- **NIM**: 434241056
- **Kelas**: B2
- **Mata Kuliah**: Mobile Praktikum
- **Tugas**: Dokumentasi API Project

---

### Deskripsi Project
**E-Ticketing Helpdesk** adalah aplikasi mobile untuk mengelola tiket support/helpdesk dengan sistem role-based access control. Aplikasi ini menggunakan Supabase sebagai backend yang menyediakan:
- Sistem Autentikasi
- Database PostgreSQL
- File Storage
- Row Level Security (RLS)

---

## Base URL
```
https://cvmzoczzdqpiucpedghp.supabase.co
```

---

## Authentication

### 1. Register
```
POST /auth/v1/signup
```
**Request:**
```json
{
  "email": "username@helpdesk.com",
  "password": "password123"
}
```
**Response:** User data dengan ID dan email

---

### 2. Login
```
POST /auth/v1/token?grant_type=password
```
**Request:**
```json
{
  "email": "username@helpdesk.com",
  "password": "password123"
}
```
**Response:** Access token dan refresh token

---

### 3. Logout
```
POST /auth/v1/logout
```
**Headers:** Authorization Bearer token

---

## Ticket Management

### 4. Create Ticket
```
POST /rest/v1/tickets
```
**Request:**
```json
{
  "user_id": "uuid-user",
  "title": "Judul Tiket",
  "description": "Deskripsi",
  "status": "pending"
}
```

---

### 5. Get All Tickets
```
GET /rest/v1/tickets
```
**Query Parameters:**
- `user_id=eq.{uuid}` - Filter by user (untuk role user)
- `status=eq.{status}` - Filter by status
- `order=created_at.desc` - Urutan descending

---

### 6. Get Ticket Detail
```
GET /rest/v1/tickets?id=eq.{ticket_id}
```

---

### 7. Update Status
```
PATCH /rest/v1/tickets?id=eq.{ticket_id}
```
**Request:**
```json
{
  "status": "on_progress",
  "updated_at": "2024-01-01T12:00:00Z"
}
```
**Status:** pending | on_progress | resolved

---

### 8. Assign Ticket
```
PATCH /rest/v1/tickets?id=eq.{ticket_id}
```
**Request:**
```json
{
  "assigned_to": "uuid-helpdesk",
  "updated_at": "2024-01-01T12:00:00Z"
}
```

---

### 9. Delete Ticket (Admin Only)
```
DELETE /rest/v1/tickets?id=eq.{ticket_id}
```

---

## Comments & History

### 10. Add Comment
```
POST /rest/v1/ticket_history
```
**Request:**
```json
{
  "ticket_id": "uuid-ticket",
  "user_id": "uuid-user",
  "action": "Comment",
  "message": "Komentar..."
}
```

---

### 11. Get History
```
GET /rest/v1/ticket_history?ticket_id=eq.{ticket_id}&order=created_at.desc
```

---

## Statistics

### 12. Get Statistics
```
GET /rest/v1/tickets?select=status
```
**Response:**
```json
{
  "total": 100,
  "pending": 30,
  "on_progress": 45,
  "resolved": 25
}
```

---

## User Profile

### 13. Get Profile
```
GET /rest/v1/profiles?id=eq.{user_id}
```
**Response:**
```json
{
  "id": "uuid",
  "full_name": "Nama",
  "username": "username",
  "role": "user"
}
```

---

### 14. Get User Ticket Count
```
GET /rest/v1/tickets?user_id=eq.{user_id}&select=id
```
**Deskripsi**: Menghitung total tiket yang dibuat oleh user
**Response:**
```json
[
  {"id": "ticket-1"},
  {"id": "ticket-2"}
]
```
**Catatan**: Total = panjang array

---

## File Upload

### 15. Upload Attachment

### 14. Upload Attachment
```
POST /storage/v1/object/ticket-attachments/{path}
```
**Path Format:** `tickets/{ticket_id}/{timestamp}-{filename}`

---

## Database Schema

### Tabel: tickets
| Field | Type | Deskripsi |
|-------|------|-----------|
| id | UUID | Primary Key |
| user_id | UUID | Foreign key ke profiles |
| title | VARCHAR(255) | Judul tiket |
| description | TEXT | Deskripsi detail |
| status | VARCHAR(20) | pending/on_progress/resolved |
| assigned_to | UUID | Helpdesk assigned |
| created_at | TIMESTAMP | Waktu pembuatan |
| updated_at | TIMESTAMP | Waktu update |

### Tabel: ticket_history
| Field | Type | Deskripsi |
|-------|------|-----------|
| id | UUID | Primary Key |
| ticket_id | UUID | Foreign key ke tickets |
| user_id | UUID | Foreign key ke profiles |
| action | VARCHAR(50) | Tipe aksi |
| message | TEXT | Pesan/komentar |
| created_at | TIMESTAMP | Waktu dibuat |

### Tabel: profiles
| Field | Type | Deskripsi |
|-------|------|-----------|
| id | UUID | Primary Key |
| full_name | VARCHAR(255) | Nama lengkap |
| username | VARCHAR(100) | Username unique |
| email | VARCHAR(255) | Email |
| role | VARCHAR(20) | user/helpdesk/admin |

---

## Role & Permissions

| Fitur | User | Helpdesk | Admin |
|-------|------|----------|-------|
| Create Ticket | ✅ | ✅ | ✅ |
| View Own Tickets | ✅ | - | - |
| View All Tickets | - | ✅ | ✅ |
| Update Status | - | ✅ | ✅ |
| Assign Ticket | - | ✅ | ✅ |
| Delete Ticket | - | - | ✅ |

---

## HTTP Status Codes

- **200 OK** - Request berhasil
- **201 Created** - Resource berhasil dibuat
- **204 No Content** - Sukses tanpa return content
- **400 Bad Request** - Request tidak valid
- **401 Unauthorized** - Authentication gagal
- **403 Forbidden** - Tidak ada akses
- **404 Not Found** - Resource tidak ditemukan
- **500 Internal Error** - Error server

---

## Security Features

1. **JWT Authentication** - Token-based auth
2. **Row Level Security (RLS)** - Data access control di database
3. **Role-based Access** - Permission berdasarkan role
4. **HTTPS Only** - Semua komunikasi terenkripsi

---

## Catatan Penting

1. **Email Format**: Sistem mengkonversi username menjadi format `username@helpdesk.com` untuk autentikasi

2. **Token Usage**: Semua request ke API (kecuali auth) memerlukan header:
   ```
   Authorization: Bearer {access_token}
   ```

3. **Data Filtering**: 
   - Role `user` otomatis filter data by user_id
   - Role `helpdesk` dan `admin` bisa melihat semua data

---

**Dokumentasi ini dibuat sebagai tugas mata kuliah Mobile Praktikum**

© 2024 Muhammad Raka Razzani - 434241056
