# E-Ticketing Helpdesk - Database Schema

## Tables Overview

```
┌─────────────────────┐
│     auth.users      │ (Supabase built-in)
├─────────────────────┤
│ id (UUID)          │
│ email              │
│ user_metadata      │ ← role, department
└─────────────────────┘
         ↓ references
┌─────────────────────┐
│      tickets        │
├─────────────────────┤
│ id (UUID)          │
│ user_id (FK)       │
│ title              │
│ description        │
│ status             │
│ assigned_to (FK)   │
│ created_at         │
│ updated_at         │
└─────────────────────┘
         ↓ references
┌─────────────────────┐
│  ticket_history     │
├─────────────────────┤
│ id (UUID)          │
│ ticket_id (FK)     │
│ user_id (FK)       │
│ action             │
│ message            │
│ status             │
│ created_at         │
└─────────────────────┘
```

## 1. Tickets Table

### Purpose
Menyimpan data utama tiket support/helpdesk.

### Schema
```sql
CREATE TABLE tickets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);
```

### Columns

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique identifier untuk tiket |
| `user_id` | UUID | NOT NULL, FK → auth.users | ID user yang membuat tiket |
| `title` | VARCHAR(255) | NOT NULL | Judul/subject tiket |
| `description` | TEXT | NOT NULL | Deskripsi detail masalah |
| `status` | VARCHAR(50) | NOT NULL, DEFAULT 'pending' | Status tiket: pending, on_progress, resolved |
| `assigned_to` | UUID | FK → auth.users (nullable) | ID user yang assign-handle tiket (helpdesk) |
| `created_at` | TIMESTAMP TZ | DEFAULT NOW() | Waktu pembuatan tiket |
| `updated_at` | TIMESTAMP TZ | nullable | Waktu update terakhir |

### Indexes
```sql
CREATE INDEX idx_tickets_user_id ON tickets(user_id);
CREATE INDEX idx_tickets_status ON tickets(status);
CREATE INDEX idx_tickets_created_at ON tickets(created_at DESC);
CREATE INDEX idx_tickets_assigned_to ON tickets(assigned_to);
```

### Constraints
- `user_id` harus ada di `auth.users`
- `assigned_to` optional (bisa NULL jika belum di-assign)
- Soft delete bisa ditambah dengan kolom `deleted_at`

### Example Data
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "user_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "title": "Login tidak bisa dengan akun premium",
  "description": "Saya tidak bisa login menggunakan akun premium saya di aplikasi mobile",
  "status": "on_progress",
  "assigned_to": "f47ac10b-58cc-4372-a567-0e02b2c3d480",
  "created_at": "2024-01-15T10:30:00+00:00",
  "updated_at": "2024-01-15T14:45:00+00:00"
}
```

## 2. Ticket History Table

### Purpose
Menyimpan audit trail dan comments untuk setiap tiket.

### Schema
```sql
CREATE TABLE ticket_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  action VARCHAR(100) NOT NULL,
  message TEXT NOT NULL,
  status VARCHAR(50),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Columns

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique identifier |
| `ticket_id` | UUID | NOT NULL, FK → tickets | Tiket mana yang di-update |
| `user_id` | UUID | NOT NULL, FK → auth.users | Siapa yang melakukan action |
| `action` | VARCHAR(100) | NOT NULL | Jenis action: 'Comment', 'Status Update', 'Assigned', 'Unassigned' |
| `message` | TEXT | NOT NULL | Isi pesan/komentar atau deskripsi action |
| `status` | VARCHAR(50) | nullable | Status baru (jika action = 'Status Update') |
| `created_at` | TIMESTAMP TZ | DEFAULT NOW() | Waktu action |

### Indexes
```sql
CREATE INDEX idx_ticket_history_ticket_id ON ticket_history(ticket_id);
CREATE INDEX idx_ticket_history_user_id ON ticket_history(user_id);
CREATE INDEX idx_ticket_history_created_at ON ticket_history(created_at DESC);
```

### Constraints
- `ticket_id` harus ada di `tickets` (ON DELETE CASCADE)
- `user_id` harus ada di `auth.users`

### Example Data
```json
{
  "id": "660e8400-e29b-41d4-a716-446655440001",
  "ticket_id": "550e8400-e29b-41d4-a716-446655440000",
  "user_id": "f47ac10b-58cc-4372-a567-0e02b2c3d480",
  "action": "Status Update",
  "message": "Status diubah menjadi on_progress",
  "status": "on_progress",
  "created_at": "2024-01-15T14:30:00+00:00"
}
```

## 3. Ticket Attachments Table

### Purpose
Menyimpan metadata file attachment untuk tiket.

### Schema
```sql
CREATE TABLE ticket_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  file_name VARCHAR(255) NOT NULL,
  file_path VARCHAR(255) NOT NULL,
  file_size INT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Columns

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique identifier |
| `ticket_id` | UUID | NOT NULL, FK | Tiket yang memiliki file |
| `file_name` | VARCHAR(255) | NOT NULL | Nama file asli |
| `file_path` | VARCHAR(255) | NOT NULL | Path di Supabase Storage |
| `file_size` | INT | nullable | Ukuran file dalam bytes |
| `created_at` | TIMESTAMP TZ | DEFAULT NOW() | Waktu upload |

### Indexes
```sql
CREATE INDEX idx_ticket_attachments_ticket_id ON ticket_attachments(ticket_id);
```

### Example Data
```json
{
  "id": "770e8400-e29b-41d4-a716-446655440002",
  "ticket_id": "550e8400-e29b-41d4-a716-446655440000",
  "file_name": "screenshot_login.png",
  "file_path": "tickets/550e8400-e29b-41d4-a716-446655440000/1705322400000-screenshot_login.png",
  "file_size": 245632,
  "created_at": "2024-01-15T14:32:00+00:00"
}
```

## 4. Auth Users Metadata

### Purpose
Menyimpan informasi tambahan user yang digunakan untuk role dan permission.

### Supabase Metadata Structure
```json
{
  "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "email": "user@example.com",
  "user_metadata": {
    "role": "user",
    "department": "IT Support",
    "name": "John Doe"
  }
}
```

### Roles
- **user**: Regular user yang bisa membuat tiket, melihat tiket mereka sendiri, dan comment
- **helpdesk**: Staff support yang bisa melihat semua tiket, update status, assign tiket
- **admin**: Admin yang memiliki akses penuh ke semua fitur

## Row Level Security (RLS)

### Policies

#### 1. Tickets Table

**SELECT Policy (View Tickets)**
```sql
-- Users dapat melihat tiket mereka sendiri
-- Admin/Helpdesk dapat melihat semua tiket
CREATE POLICY "view_tickets_policy" ON tickets
FOR SELECT
USING (
  auth.uid() = user_id 
  OR (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE id = auth.uid() 
      AND raw_user_meta_data->>'role' IN ('admin', 'helpdesk')
    )
  )
);
```

**INSERT Policy (Create Tickets)**
```sql
-- Users dapat membuat tiket untuk diri sendiri
CREATE POLICY "create_tickets_policy" ON tickets
FOR INSERT
WITH CHECK (auth.uid() = user_id);
```

**UPDATE Policy (Update Tickets)**
```sql
-- Admin/Helpdesk dapat update tiket
CREATE POLICY "update_tickets_policy" ON tickets
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'role' IN ('admin', 'helpdesk')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'role' IN ('admin', 'helpdesk')
  )
);
```

**DELETE Policy (Delete Tickets)**
```sql
-- Hanya admin yang dapat delete
CREATE POLICY "delete_tickets_policy" ON tickets
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'role' = 'admin'
  )
);
```

#### 2. Ticket History Table

**SELECT Policy**
```sql
-- Users dapat melihat history tiket mereka
-- Admin/Helpdesk dapat melihat semua history
CREATE POLICY "view_history_policy" ON ticket_history
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM tickets 
    WHERE tickets.id = ticket_history.ticket_id
    AND (
      auth.uid() = tickets.user_id
      OR EXISTS (
        SELECT 1 FROM auth.users 
        WHERE id = auth.uid() 
        AND raw_user_meta_data->>'role' IN ('admin', 'helpdesk')
      )
    )
  )
);
```

**INSERT Policy**
```sql
-- Siapa saja authenticated user dapat insert history
CREATE POLICY "insert_history_policy" ON ticket_history
FOR INSERT
WITH CHECK (auth.uid() = user_id);
```

## Data Relationships

### Ticket → User (Creator)
```
tickets.user_id → auth.users.id (1:N)
- Satu user bisa membuat banyak tiket
```

### Ticket → User (Assigned)
```
tickets.assigned_to → auth.users.id (0..1:N)
- Satu user bisa di-assign multiple tikets
- Bisa NULL jika belum di-assign
```

### Ticket → History (1:N)
```
tickets.id → ticket_history.ticket_id
- Satu tiket bisa memiliki banyak history entries
- ON DELETE CASCADE: history dihapus saat tiket dihapus
```

### Ticket → Attachment (1:N)
```
tickets.id → ticket_attachments.ticket_id
- Satu tiket bisa memiliki banyak attachment
- ON DELETE CASCADE: attachment dihapus saat tiket dihapus
```

## Migration Strategy

### V1 (Initial)
```sql
-- Create all tables with basic structure
-- Create indexes
-- Enable RLS
-- Create policies
```

### V2 (Future Enhancements)
```sql
-- Add priority level
-- Add category/department
-- Add urgency level
-- Add sla tracking
-- Add custom fields
```

## Performance Considerations

1. **Indexing**: Indexes pada `user_id`, `status`, `assigned_to` untuk frequent queries
2. **Partitioning**: Consider partitioning `ticket_history` by date untuk large datasets
3. **Caching**: Cache frequently accessed tickets di client-side
4. **Pagination**: Always paginate large result sets
5. **Cleanup**: Archive old tickets untuk better performance

## Backup Strategy

1. Enable automated backups di Supabase
2. Regular exports untuk disaster recovery
3. Point-in-time recovery setup

