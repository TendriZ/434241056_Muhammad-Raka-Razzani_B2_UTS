# E-Ticketing Helpdesk - Feature Requirements

## Overview
Dokumen ini menjelaskan setiap functional requirement (FR) beserta implementasinya dalam Clean Architecture.

## FR-001: Sistem Autentikasi & Manajemen Pengguna

### Deskripsi
Sistem autentikasi yang aman dengan support untuk berbagai roles: User, Helpdesk Staff, dan Admin.

### User Stories
- Sebagai user baru, saya ingin sign up dengan email dan password
- Sebagai user, saya ingin login ke aplikasi
- Sebagai user, saya ingin logout
- Sebagai user, saya ingin reset password jika lupa
- Sistem harus bisa mengidentifikasi role user (user/helpdesk/admin)

### Technical Implementation

**Domain Layer (Business Rules):**
```dart
// lib/features/auth/domain/entities/user_entity.dart
class UserEntity {
  final String id;
  final String email;
  final String role; // 'user', 'helpdesk', 'admin'
  final DateTime createdAt;
}
```

**Data Layer (Supabase Auth):**
```dart
// lib/features/auth/data/datasources/auth_remote_datasource.dart
Future<UserEntity> signUp(String email, String password);
Future<UserEntity> signIn(String email, String password);
Future<void> signOut();
Future<void> resetPassword(String email);
UserEntity? getCurrentUser();
```

**Integration Points:**
- Supabase Auth untuk authentication
- Store role di `auth.users.raw_user_meta_data`
- JWT token untuk API calls

### Dependencies
- supabase_flutter
- equatable
- get_it

---

## FR-005: Membuat Tiket

### Deskripsi
User dapat membuat tiket support baru dengan judul, deskripsi, dan optional file attachment.

### User Stories
- Sebagai user, saya ingin membuat tiket dengan judul dan deskripsi
- Sistem harus validate input sebelum submit
- Setelah tiket berhasil dibuat, sistem harus menampilkan confirmation
- User dapat upload file attachment ketika membuat tiket
- Tiket yang dibuat harus tersimpan di database dengan status "pending"

### Technical Implementation

**Domain Layer:**
```dart
// Use Case
class CreateTicketUseCase {
  Future<TicketEntity> call({
    required String title,
    required String description,
  });
}
```

**Presentation Layer:**
```dart
// CreateTicketScreen menangani:
// 1. Form input validation
// 2. Display loading state saat submit
// 3. Show success/error message
// 4. Navigate back ke list
```

**Data Flow:**
```
CreateTicketEvent
  ↓
_onCreateTicket()
  ↓
createTicketUseCase.call()
  ↓
repository.createTicket()
  ↓
remoteDataSource.createTicket() [Supabase POST]
  ↓
TicketModel.fromJson()
  ↓
emit(TicketSuccess())
  ↓
Show confirmation dialog
```

### Validation Rules
- Title minimal 5 karakter
- Description minimal 10 karakter
- Attachment file size max 10MB
- Supported formats: PDF, Images, Word

### Database Changes
```sql
INSERT INTO tickets (user_id, title, description, status, created_at)
VALUES ($1, $2, $3, 'pending', NOW())
```

---

## FR-005.2: Upload File Attachment

### Deskripsi
User dapat upload file ke tiket untuk memberikan informasi tambahan seperti screenshot.

### User Stories
- Saya ingin upload file ketika membuat tiket
- Saya ingin upload file saat menambah komentar
- File harus tersimpan aman di cloud storage
- Saya bisa download file attachment yang sudah diupload

### Technical Implementation

**Data Layer:**
```dart
// Upload ke Supabase Storage
Future<String> uploadTicketAttachment({
  required String ticketId,
  required List<int> fileBytes,
  required String fileName,
}) async {
  final filePath = 'tickets/$ticketId/$timestamp-$fileName';
  await supabaseClient.storage
    .from('ticket-attachments')
    .uploadBinary(filePath, fileBytes);
  
  return getPublicUrl(filePath);
}
```

**Security:**
- File disimpan di private storage bucket
- Akses diproteksi dengan RLS
- Scan for malware (future)

---

## FR-006: Menampilkan Daftar Tiket

### Deskripsi
User dapat melihat daftar tiket dengan filtering berdasarkan role dan status.

### User Stories
- Sebagai user, saya ingin melihat tiket saya sendiri
- Sebagai helpdesk, saya ingin melihat semua tiket dari semua user
- Sebagai admin, saya ingin melihat semua tiket
- Saya ingin filter tiket berdasarkan status (pending, on_progress, resolved)
- Saya ingin sort tiket berdasarkan tanggal pembuatan
- Saya ingin search tiket berdasarkan title atau deskripsi
- List harus support pagination untuk performa

### Technical Implementation

**Domain Layer:**
```dart
class GetTicketsUseCase {
  Future<List<TicketEntity>> call({
    String? userId,
    String? role,
  });
}
```

**Data Source (Role-based Filtering):**
```dart
Future<List<TicketModel>> getTickets({
  String? userId,
  String? role,
}) async {
  var query = supabaseClient.from('tickets').select();
  
  // Role-based filtering
  if (role == 'user' && userId != null) {
    query = query.eq('user_id', userId); // User hanya lihat punya sendiri
  }
  // Admin/Helpdesk lihat semua
  
  return query.order('created_at', ascending: false);
}
```

**Presentation Layer:**
```dart
// TicketListScreen menampilkan:
// 1. Filter tab (All, Pending, On Progress, Resolved)
// 2. Ticket cards dengan:
//    - Title
//    - Status badge dengan warna
//    - Created date
//    - Tap to view detail
// 3. Pull-to-refresh
// 4. Empty state message
```

### Filtering Logic
```
Role = 'user' → Only own tickets
Role = 'helpdesk' → All tickets
Role = 'admin' → All tickets + delete option
```

---

## FR-006.3: Update Status Tiket

### Deskripsi
Helpdesk/Admin dapat mengubah status tiket dari pending → on_progress → resolved.

### User Stories
- Sebagai helpdesk, saya ingin update status tiket
- Status dapat diubah dari pending ke on_progress
- Status dapat diubah dari on_progress ke resolved
- Perubahan status harus tercatat di history
- User yang membuat tiket harus bisa melihat status update

### Technical Implementation

**Domain Layer:**
```dart
class UpdateTicketStatusUseCase {
  Future<bool> call({
    required String ticketId,
    required String newStatus,
  });
}
```

**Status Transitions:**
```
pending → on_progress → resolved
         ↓
         resolved

resolved → ? (tidak bisa di-update)
```

**Data Flow:**
```
1. Validate newStatus adalah valid value
2. Update tickets.status
3. Update tickets.updated_at
4. Insert ke ticket_history dengan action = 'Status Update'
5. Emit TicketSuccess state
6. Refresh detail view
```

---

## FR-006.4: Assign Tiket

### Deskripsi
Helpdesk/Admin dapat assign tiket ke staff untuk ditangani.

### User Stories
- Sebagai admin, saya ingin assign tiket ke helpdesk staff
- Saya ingin lihat siapa yang handle tiket ini
- Staff yang di-assign harus menerima notifikasi (future)

### Technical Implementation

**Data Layer:**
```dart
Future<bool> assignTicket({
  required String ticketId,
  required String assignedTo,
}) async {
  // 1. Update tickets.assigned_to
  await supabaseClient.from('tickets').update({
    'assigned_to': assignedTo,
    'updated_at': DateTime.now().toIso8601String(),
  }).eq('id', ticketId);
  
  // 2. Log ke history
  await supabaseClient.from('ticket_history').insert({
    'ticket_id': ticketId,
    'user_id': currentUserId,
    'action': 'Assigned',
    'message': 'Tiket ditugaskan ke $assignedTo',
    'created_at': DateTime.now().toIso8601String(),
  });
  
  return true;
}
```

---

## FR-007: Tambah Komentar

### Deskripsi
User/Helpdesk dapat menambah komentar untuk komunikasi dalam tiket.

### User Stories
- Saya ingin menambah komentar ke tiket
- Komentar harus tersimpan dengan timestamp
- Saya ingin melihat semua komentar di detail view
- Komentar harus menampilkan nama pembuat dan waktu

### Technical Implementation

**Data Source:**
```dart
Future<bool> addTicketComment({
  required String ticketId,
  required String userId,
  required String message,
}) async {
  await supabaseClient.from('ticket_history').insert({
    'ticket_id': ticketId,
    'user_id': userId,
    'action': 'Comment',
    'message': message,
    'created_at': DateTime.now().toIso8601String(),
  });
  
  return true;
}
```

**Presentation:**
```dart
// Dalam TicketDetailScreen:
// - Form untuk input komentar
// - List komentar dari ticket_history
// - Real-time update (future dengan subscriptions)
```

---

## FR-010: Riwayat Tiket

### Deskripsi
Menampilkan complete audit trail dari semua perubahan yang terjadi pada tiket.

### User Stories
- Saya ingin lihat history lengkap dari tiket ini
- History harus menampilkan semua status updates
- History harus menampilkan semua comments
- History harus menampilkan assign history
- Setiap entry harus punya timestamp

### Technical Implementation

**Domain Layer:**
```dart
class GetTicketHistoryUseCase {
  Future<List<TicketHistoryEntity>> call({
    required String ticketId,
  });
}
```

**Data Source:**
```dart
Future<List<TicketHistoryModel>> getTicketHistory({
  required String ticketId,
}) async {
  final response = await supabaseClient
    .from('ticket_history')
    .select()
    .eq('ticket_id', ticketId)
    .order('created_at', ascending: false);
  
  return response.map(TicketHistoryModel.fromJson).toList();
}
```

**Presentation:**
```dart
// TicketDetailScreen menampilkan:
// - Timeline view dengan entries
// - Setiap entry punya:
//   - Action type badge (Status Update, Comment, Assigned)
//   - Message/description
//   - Timestamp
//   - User name (future)
```

---

## FR-011: Dashboard & Statistik

### Deskripsi
Dashboard yang menampilkan overview dan statistik tiket berdasarkan role.

### User Stories
- Saya ingin melihat statistik tiket saya (user) atau team (helpdesk/admin)
- Dashboard harus menampilkan:
  - Total tiket
  - Tiket pending
  - Tiket on_progress
  - Tiket resolved
- Saya ingin melihat chart distribusi status
- Saya ingin quick access ke create tiket dan list tiket

### Technical Implementation

**Domain Layer:**
```dart
class GetTicketStatisticsUseCase {
  Future<Map<String, int>> call({String? userId});
}
```

**Data Source:**
```dart
Future<Map<String, int>> getTicketStatistics({String? userId}) async {
  var query = supabaseClient.from('tickets').select('status');
  
  if (userId != null) {
    query = query.eq('user_id', userId);
  }
  
  final response = await query;
  
  // Count berdasarkan status
  int total = response.length;
  int pending = (response as List).where((e) => e['status'] == 'pending').length;
  int onProgress = response.where((e) => e['status'] == 'on_progress').length;
  int resolved = response.where((e) => e['status'] == 'resolved').length;
  
  return {
    'total': total,
    'pending': pending,
    'on_progress': onProgress,
    'resolved': resolved,
  };
}
```

**Presentation:**
```dart
// DashboardScreen menampilkan:
// - Stat cards (Total, Pending, On Progress, Resolved)
// - Chart dengan warna berbeda untuk setiap status
// - Quick action buttons
// - Welcome message
```

---

## Summary Implementation Checklist

### Data Layer
- [x] ticket_remote_datasource.dart - Semua operations
- [x] ticket_model.dart - JSON serialization
- [x] ticket_repository_impl.dart - Repository implementation

### Domain Layer
- [x] ticket_entity.dart - Entity definitions
- [x] ticket_repository.dart - Repository interface
- [x] ticket_usecases.dart - Semua use cases

### Presentation Layer
- [x] ticket_bloc.dart - State management
- [x] ticket_list_screen.dart - FR-006
- [x] create_ticket_screen.dart - FR-005
- [x] ticket_detail_screen.dart - FR-006, FR-006.3, FR-006.4, FR-007, FR-010
- [x] dashboard_screen.dart - FR-011

### Infrastructure
- [x] injection_container.dart - Dependency injection
- [x] ticket_routes.dart - Route configuration

### Database
- [x] DATABASE_SCHEMA.md - Table definitions
- [x] RLS Policies - Security

---

## Testing Requirements

### Unit Tests
- Test use cases dengan mocked repository
- Test repository dengan mocked data source
- Test model JSON serialization

### Integration Tests
- Test real Supabase integration
- Test authentication flow
- Test CRUD operations

### Widget Tests
- Test screens dengan mocked BLoC
- Test form validation
- Test error states

---

## Performance Requirements

1. **List Loading**: < 2s untuk 100 tikets
2. **Detail Loading**: < 1s untuk single tiket
3. **Upload**: < 30s untuk file 10MB
4. **Database Queries**: Indexed untuk performance
5. **Memory**: App size < 50MB

---

## Security Requirements

1. **Authentication**: Supabase Auth dengan JWT
2. **Authorization**: RLS policies di database level
3. **Data Encryption**: HTTPS untuk semua API calls
4. **Input Validation**: Validated di UI dan server
5. **Error Messages**: User-friendly tanpa sensitive data

