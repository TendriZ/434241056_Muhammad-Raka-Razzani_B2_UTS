# Dokumentasi API E-Ticketing Helpdesk

## Informasi Umum

**Project**: E-Ticketing Helpdesk Mobile Application  
**Versi**: 1.0.0  
**Base URL**: `https://cvmzoczzdqpiucpedghp.supabase.co`  
**Backend**: Supabase (PostgreSQL + Auth + Storage)  
**Tipe Authentication**: Bearer Token (JWT)

---

## Daftar Endpoint

### Authentication Module
| No | Endpoint | Method | Deskripsi |
|----|----------|--------|-----------|
| 1 | `/auth/v1/signup` | POST | Register pengguna baru |
| 2 | `/auth/v1/token?grant_type=password` | POST | Login pengguna |
| 3 | `/auth/v1/logout` | POST | Logout pengguna |
| 4 | `/auth/v1/user` | GET | Mendapatkan data user saat ini |
| 5 | `/auth/v1/recover` | POST | Request reset password |
| 6 | `/auth/v1/verify` | POST | Verifikasi OTP reset password |

### Ticket Module
| No | Endpoint | Method | Deskripsi |
|----|----------|--------|-----------|
| 7 | `/rest/v1/tickets` | POST | Membuat tiket baru |
| 8 | `/rest/v1/tickets` | GET | Mendapatkan daftar tiket |
| 9 | `/rest/v1/tickets?id=eq.{id}` | GET | Mendapatkan detail tiket |
| 10 | `/rest/v1/tickets?id=eq.{id}` | PATCH | Update status tiket |
| 11 | `/rest/v1/tickets?id=eq.{id}` | PATCH | Assign tiket ke helpdesk |
| 12 | `/rest/v1/tickets?id=eq.{id}` | DELETE | Menghapus tiket (Admin only) |
| 13 | `/rest/v1/ticket_history` | POST | Menambahkan komentar |
| 14 | `/rest/v1/ticket_history?ticket_id=eq.{id}` | GET | Mendapatkan history tiket |
| 15 | `/rest/v1/tickets?select=status` | GET | Mendapatkan statistik tiket |

### Profile Module
| No | Endpoint | Method | Deskripsi |
|----|----------|--------|-----------|
| 16 | `/rest/v1/profiles?id=eq.{id}` | GET | Mendapatkan profil user |
| 17 | `/rest/v1/profiles` | POST | Membuat profil user |
| 18 | `/rest/v1/tickets?user_id=eq.{user_id}&select=id` | GET | Mendapatkan total tiket user |

### Storage Module
| No | Endpoint | Method | Deskripsi |
|----|----------|--------|-----------|
| 18 | `/storage/v1/object/ticket-attachments/{path}` | POST | Upload file attachment |
| 19 | `/storage/v1/object/ticket-attachments/{path}` | GET | Download file attachment |

---

## Detail Endpoint API

### 1. Register Pengguna Baru

**Endpoint**: `POST /auth/v1/signup`  
**Deskripsi**: Mendaftarkan pengguna baru ke sistem

**Request Headers**:
```
Content-Type: application/json
apikey: {SUPABASE_ANON_KEY}
```

**Request Body**:
```json
{
  "email": "username@helpdesk.com",
  "password": "password123",
  "options": {
    "data": {
      "full_name": "Nama Lengkap",
      "username": "username"
    }
  }
}
```

**Response Success (201)**:
```json
{
  "id": "uuid-user-id",
  "email": "username@helpdesk.com",
  "user_metadata": {
    "full_name": "Nama Lengkap"
  },
  "created_at": "2024-01-01T00:00:00Z"
}
```

**Response Error (400)**:
```json
{
  "error": "User already registered"
}
```

**Catatan**: Email dikonversi menjadi format `{username}@helpdesk.com`

---

### 2. Login Pengguna

**Endpoint**: `POST /auth/v1/token?grant_type=password`  
**Deskripsi**: Autentikasi pengguna dengan username dan password

**Request Headers**:
```
Content-Type: application/json
apikey: {SUPABASE_ANON_KEY}
```

**Request Body**:
```json
{
  "email": "username@helpdesk.com",
  "password": "password123"
}
```

**Response Success (200)**:
```json
{
  "access_token": "jwt-access-token",
  "refresh_token": "jwt-refresh-token",
  "user": {
    "id": "uuid-user-id",
    "email": "username@helpdesk.com"
  }
}
```

**Response Error (401)**:
```json
{
  "error": "Invalid login credentials"
}
```

---

### 3. Logout Pengguna

**Endpoint**: `POST /auth/v1/logout`  
**Deskripsi**: Mengakhiri sesi pengguna

**Request Headers**:
```
Authorization: Bearer {access_token}
apikey: {SUPABASE_ANON_KEY}
```

**Response Success (204)**: No Content

---

### 4. Mendapatkan Data User Saat Ini

**Endpoint**: `GET /auth/v1/user`  
**Deskripsi**: Mendapatkan informasi user yang sedang login

**Request Headers**:
```
Authorization: Bearer {access_token}
apikey: {SUPABASE_ANON_KEY}
```

**Response Success (200)**:
```json
{
  "id": "uuid-user-id",
  "email": "username@helpdesk.com",
  "user_metadata": {
    "full_name": "Nama Lengkap"
  },
  "created_at": "2024-01-01T00:00:00Z"
}
```

---

### 5. Request Reset Password

**Endpoint**: `POST /auth/v1/recover`  
**Deskripsi**: Mengirim email reset password

**Request Headers**:
```
Content-Type: application/json
apikey: {SUPABASE_ANON_KEY}
```

**Request Body**:
```json
{
  "email": "username@helpdesk.com"
}
```

**Response Success (200)**:
```json
{
  "message": "Reset email sent"
}
```

---

### 6. Membuat Tiket Baru

**Endpoint**: `POST /rest/v1/tickets`  
**Deskripsi**: Membuat tiket support baru

**Request Headers**:
```
Content-Type: application/json
Authorization: Bearer {access_token}
apikey: {SUPABASE_ANON_KEY}
Prefer: return=representation
```

**Request Body**:
```json
{
  "user_id": "uuid-user-id",
  "title": "Judul Tiket",
  "description": "Deskripsi detail masalah",
  "status": "pending",
  "priority": "normal",
  "category": "technical"
}
```

**Response Success (201)**:
```json
{
  "id": "uuid-ticket-id",
  "user_id": "uuid-user-id",
  "title": "Judul Tiket",
  "description": "Deskripsi detail masalah",
  "status": "pending",
  "priority": "normal",
  "category": "technical",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

---

### 7. Mendapatkan Daftar Tiket

**Endpoint**: `GET /rest/v1/tickets`  
**Deskripsi**: Mendapatkan daftar tiket berdasarkan role user

**Request Headers**:
```
Authorization: Bearer {access_token}
apikey: {SUPABASE_ANON_KEY}
```

**Query Parameters**:
- `user_id`: Filter tiket berdasarkan user (untuk role 'user')
- `status`: Filter berdasarkan status (pending, on_progress, resolved)
- `order`: Urutan hasil (default: created_at.desc)

**Contoh Request**:
```
GET /rest/v1/tickets?user_id=eq.{uuid}&order=created_at.desc
GET /rest/v1/tickets?status=eq.pending&order=created_at.desc
GET /rest/v1/tickets?order=created_at.desc
```

**Response Success (200)**:
```json
[
  {
    "id": "uuid-ticket-1",
    "user_id": "uuid-user-id",
    "title": "Judul Tiket 1",
    "description": "Deskripsi tiket 1",
    "status": "pending",
    "assigned_to": null,
    "created_at": "2024-01-01T10:00:00Z",
    "updated_at": "2024-01-01T10:00:00Z"
  },
  {
    "id": "uuid-ticket-2",
    "user_id": "uuid-user-id",
    "title": "Judul Tiket 2",
    "description": "Deskripsi tiket 2",
    "status": "on_progress",
    "assigned_to": "uuid-helpdesk-id",
    "created_at": "2024-01-01T09:00:00Z",
    "updated_at": "2024-01-01T11:00:00Z"
  }
]
```

---

### 8. Mendapatkan Detail Tiket

**Endpoint**: `GET /rest/v1/tickets?id=eq.{ticket_id}`  
**Deskripsi**: Mendapatkan detail lengkap sebuah tiket

**Request Headers**:
```
Authorization: Bearer {access_token}
apikey: {SUPABASE_ANON_KEY}
```

**Response Success (200)**:
```json
{
  "id": "uuid-ticket-id",
  "user_id": "uuid-user-id",
  "title": "Judul Tiket",
  "description": "Deskripsi detail masalah",
  "status": "pending",
  "priority": "normal",
  "category": "technical",
  "assigned_to": null,
  "created_at": "2024-01-01T10:00:00Z",
  "updated_at": "2024-01-01T10:00:00Z"
}
```

**Response Error (404)**:
```json
{
  "error": "Ticket not found"
}
```

---

### 9. Update Status Tiket

**Endpoint**: `PATCH /rest/v1/tickets?id=eq.{ticket_id}`  
**Deskripsi**: Mengubah status tiket (Helpdesk & Admin only)

**Request Headers**:
```
Content-Type: application/json
Authorization: Bearer {access_token}
apikey: {SUPABASE_ANON_KEY}
Prefer: return=representation
```

**Request Body**:
```json
{
  "status": "on_progress",
  "updated_at": "2024-01-01T12:00:00Z"
}
```

**Status yang valid**:
- `pending` - Tiket baru dibuat
- `on_progress` - Tiket sedang diproses
- `resolved` - Tiket selesai

**Response Success (200)**:
```json
{
  "id": "uuid-ticket-id",
  "status": "on_progress",
  "updated_at": "2024-01-01T12:00:00Z"
}
```

---

### 10. Assign Tiket ke Helpdesk

**Endpoint**: `PATCH /rest/v1/tickets?id=eq.{ticket_id}`  
**Deskripsi**: Menugaskan tiket ke helpdesk staff

**Request Headers**:
```
Content-Type: application/json
Authorization: Bearer {access_token}
apikey: {SUPABASE_ANON_KEY}
```

**Request Body**:
```json
{
  "assigned_to": "uuid-helpdesk-id",
  "updated_at": "2024-01-01T12:00:00Z"
}
```

**Response Success (200)**:
```json
{
  "id": "uuid-ticket-id",
  "assigned_to": "uuid-helpdesk-id",
  "updated_at": "2024-01-01T12:00:00Z"
}
```

---

### 11. Hapus Tiket

**Endpoint**: `DELETE /rest/v1/tickets?id=eq.{ticket_id}`  
**Deskripsi**: Menghapus tiket (Admin only)

**Request Headers**:
```
Authorization: Bearer {access_token}
apikey: {SUPABASE_ANON_KEY}
```

**Response Success (204)**: No Content

**Response Error (403)**:
```json
{
  "error": "Insufficient permissions"
}
```

---

### 12. Menambahkan Komentar

**Endpoint**: `POST /rest/v1/ticket_history`  
**Deskripsi**: Menambahkan komentar atau update ke tiket

**Request Headers**:
```
Content-Type: application/json
Authorization: Bearer {access_token}
apikey: {SUPABASE_ANON_KEY}
Prefer: return=representation
```

**Request Body**:
```json
{
  "ticket_id": "uuid-ticket-id",
  "user_id": "uuid-user-id",
  "action": "Comment",
  "message": "Ini adalah komentar tiket",
  "created_at": "2024-01-01T12:00:00Z"
}
```

**Action yang valid**:
- `Comment` - Komentar biasa
- `Status Update` - Update status
- `Assigned` - Penugasan tiket

**Response Success (201)**:
```json
{
  "id": "uuid-history-id",
  "ticket_id": "uuid-ticket-id",
  "user_id": "uuid-user-id",
  "action": "Comment",
  "message": "Ini adalah komentar tiket",
  "created_at": "2024-01-01T12:00:00Z"
}
```

---

### 13. Mendapatkan History Tiket

**Endpoint**: `GET /rest/v1/ticket_history?ticket_id=eq.{ticket_id}&order=created_at.desc`  
**Deskripsi**: Mendapatkan semua history perubahan tiket

**Request Headers**:
```
Authorization: Bearer {access_token}
apikey: {SUPABASE_ANON_KEY}
```

**Response Success (200)**:
```json
[
  {
    "id": "uuid-history-1",
    "ticket_id": "uuid-ticket-id",
    "user_id": "uuid-user-id",
    "action": "Comment",
    "message": "Komentar terbaru",
    "created_at": "2024-01-01T12:00:00Z"
  },
  {
    "id": "uuid-history-2",
    "ticket_id": "uuid-ticket-id",
    "user_id": "uuid-helpdesk-id",
    "action": "Status Update",
    "message": "Status diubah menjadi on_progress",
    "created_at": "2024-01-01T11:00:00Z"
  }
]
```

---

### 14. Mendapatkan Statistik Tiket

**Endpoint**: `GET /rest/v1/tickets?select=status`  
**Deskripsi**: Mendapatkan statistik tiket berdasarkan status

**Request Headers**:
```
Authorization: Bearer {access_token}
apikey: {SUPABASE_ANON_KEY}
```

**Query Parameters**:
- `user_id`: Filter statistik per user (optional)

**Response Success (200)**:
```json
{
  "total": 100,
  "pending": 30,
  "on_progress": 45,
  "resolved": 25
}
```

---

### 15. Mendapatkan Profil User

**Endpoint**: `GET /rest/v1/profiles?id=eq.{user_id}`  
**Deskripsi**: Mendapatkan data profil user lengkap

**Request Headers**:
```
Authorization: Bearer {access_token}
apikey: {SUPABASE_ANON_KEY}
```

**Response Success (200)**:
```json
{
  "id": "uuid-user-id",
  "full_name": "Nama Lengkap",
  "username": "username",
  "email": "username@helpdesk.com",
  "role": "user",
  "avatar_url": "https://example.com/avatar.jpg",
  "created_at": "2024-01-01T00:00:00Z"
}
```

**Role yang tersedia**:
- `user` - Pengguna biasa
- `helpdesk` - Staff helpdesk
- `admin` - Administrator

---

### 16. Mendapatkan Total Tiket User

**Endpoint**: `GET /rest/v1/tickets?user_id=eq.{user_id}&select=id`  
**Deskripsi**: Menghitung total tiket yang dibuat oleh user tertentu

**Request Headers**:
```
Authorization: Bearer {access_token}
apikey: {SUPABASE_ANON_KEY}
```

**Query Parameters**:
- `user_id=eq.{uuid}` - Filter tiket berdasarkan user ID
- `select=id` - Hanya select ID untuk efisiensi (count by array length)

**Contoh Request**:
```
GET /rest/v1/tickets?user_id=eq.123e4567-e89b-12d3-a456-426614174000&select=id
```

**Response Success (200)**:
```json
[
  {"id": "uuid-ticket-1"},
  {"id": "uuid-ticket-2"},
  {"id": "uuid-ticket-3"}
]
```

**Catatan**: Total tiket dihitung dari panjang array response (dalam contoh: 3 tiket)

---

### 17. Upload File Attachment

**Endpoint**: `POST /storage/v1/object/ticket-attachments/{path}`  
**Deskripsi**: Upload file lampiran ke tiket

**Request Headers**:
```
Authorization: Bearer {access_token}
apikey: {SUPABASE_ANON_KEY}
Content-Type: multipart/form-data
```

**Path Format**:
```
tickets/{ticket_id}/{timestamp}-{filename}
```

**Request Body**:
- File binary (multipart/form-data)

**Response Success (200)**:
```json
{
  "Key": "tickets/uuid-ticket-id/1704110400000-screenshot.png",
  "publicUrl": "https://cvmzoczzdqpiucpedghp.supabase.co/storage/v1/object/public/ticket-attachments/tickets/uuid-ticket-id/1704110400000-screenshot.png"
}
```

---

## Struktur Database

### Table: profiles
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  full_name VARCHAR(255),
  username VARCHAR(100) UNIQUE NOT NULL,
  email VARCHAR(255),
  role VARCHAR(20) DEFAULT 'user',
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Table: tickets
```sql
CREATE TABLE tickets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  status VARCHAR(20) DEFAULT 'pending',
  priority VARCHAR(20) DEFAULT 'normal',
  category VARCHAR(50),
  assigned_to UUID REFERENCES profiles(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Table: ticket_history
```sql
CREATE TABLE ticket_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ticket_id UUID REFERENCES tickets(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id),
  action VARCHAR(50),
  message TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

## Kode Status HTTP

| Kode | Deskripsi |
|------|-----------|
| 200 | OK - Request berhasil |
| 201 | Created - Resource berhasil dibuat |
| 204 | No Content - Request berhasil tanpa return content |
| 400 | Bad Request - Request tidak valid |
| 401 | Unauthorized - Authentication gagal |
| 403 | Forbidden - Tidak ada akses |
| 404 | Not Found - Resource tidak ditemukan |
| 500 | Internal Server Error - Error server |

---

## Row Level Security (RLS)

### Policies yang diterapkan:

1. **Tickets**
   - Users hanya bisa melihat tiket miliknya sendiri
   - Helpdesk dan Admin bisa melihat semua tiket
   - Hanya Admin yang bisa menghapus tiket

2. **Profiles**
   - Users bisa mengupdate profil sendiri
   - Helpdesk dan Admin bisa melihat semua profil

3. **Ticket History**
   - Users bisa melihat history tiket miliknya
   - Helpdesk dan Admin bisa melihat semua history

---

## Contoh Penggunaan dengan cURL

### Login
```bash
curl -X POST 'https://cvmzoczzdqpiucpedghp.supabase.co/auth/v1/token?grant_type=password' \
  -H 'Content-Type: application/json' \
  -H 'apikey: YOUR_ANON_KEY' \
  -d '{
    "email": "user@helpdesk.com",
    "password": "password123"
  }'
```

### Create Ticket
```bash
curl -X POST 'https://cvmzoczzdqpiucpedghp.supabase.co/rest/v1/tickets' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \
  -H 'apikey: YOUR_ANON_KEY' \
  -H 'Prefer: return=representation' \
  -d '{
    "user_id": "user-uuid",
    "title": "Problem dengan login",
    "description": "Tidak bisa login ke sistem",
    "status": "pending"
  }'
```

### Get Tickets
```bash
curl -X GET 'https://cvmzoczzdqpiucpedghp.supabase.co/rest/v1/tickets?order=created_at.desc' \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \
  -H 'apikey: YOUR_ANON_KEY'
```

---

## Error Handling

### Format Error Response
```json
{
  "error": "Error message",
  "message": "Detailed error description",
  "status": 400
}
```

### Common Errors

| Error | Penyebab | Solusi |
|-------|----------|--------|
| `Invalid login credentials` | Username/password salah | Periksa kembali kredensial |
| `User already registered` | Username sudah dipakai | Gunakan username lain |
| `JWT expired` | Token sudah kadaluars | Login kembali untuk token baru |
| `Insufficient permissions` | Tidak ada akses | Hubungi administrator |
| `Ticket not found` | Tiket tidak ada | Periksa ID tiket |

---

## Catatan Penting

1. **Authentication Format**: Email dikonversi menjadi `{username}@helpdesk.com` untuk login

2. **Role-based Access**: 
   - `user` - Hanya bisa melihat dan membuat tiket sendiri
   - `helpdesk` - Bisa melihat semua tiket, update status, assign tiket
   - `admin` - Full access termasuk delete tiket

3. **Timestamp Format**: Semua timestamp menggunakan format ISO 8601 UTC

4. **Pagination**: Untuk endpoint yang mengembalikan list, gunakan parameter `limit` dan `offset`

5. **Storage**: File attachment disimpan di bucket `ticket-attachments` dengan public access

---

## Kontak & Support

**Developer**: Muhammad Raka Razzani  
**NIM**: 434241056  
**Project**: E-Ticketing Helpdesk  
**Tahun**: 2024

---

*Dokumentasi ini dibuat untuk keperluan tugas mata kuliah Mobile Praktikum*
