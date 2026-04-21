# E-Ticketing Helpdesk - API Guide

## Base URL
```
https://[YOUR_PROJECT_ID].supabase.co
```

## Authentication

### Header Required
```
Authorization: Bearer [ACCESS_TOKEN]
Content-Type: application/json
```

### Get Access Token
```dart
final session = supabase.auth.currentSession;
final token = session?.accessToken;
```

## REST API Endpoints

### Tickets

#### 1. Create Ticket (FR-005)
**POST** `/rest/v1/tickets`

**Request Body:**
```json
{
  "user_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "title": "Login tidak bisa",
  "description": "Saya tidak bisa login ke aplikasi",
  "status": "pending"
}
```

**Response (201 Created):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "user_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "title": "Login tidak bisa",
  "description": "Saya tidak bisa login ke aplikasi",
  "status": "pending",
  "assigned_to": null,
  "created_at": "2024-01-15T10:30:00+00:00",
  "updated_at": null
}
```

**Dart Implementation:**
```dart
Future<TicketModel> createTicket({
  required String userId,
  required String title,
  required String description,
}) async {
  final response = await supabaseClient
    .from('tickets')
    .insert({
      'user_id': userId,
      'title': title,
      'description': description,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    })
    .select()
    .single();
  
  return TicketModel.fromJson(response);
}
```

#### 2. Get All Tickets (FR-006)
**GET** `/rest/v1/tickets`

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `select` | string | Columns to select (default: *) |
| `order` | string | Order by column (e.g., `created_at.desc`) |
| `limit` | integer | Number of results (pagination) |
| `offset` | integer | Skip n results (pagination) |
| `user_id` | string | Filter by user_id (eq) |
| `status` | string | Filter by status (eq) |

**Examples:**
```bash
# Get all tickets ordered by created_at descending
GET /rest/v1/tickets?select=*&order=created_at.desc

# Get user's tickets with limit
GET /rest/v1/tickets?select=*&user_id=eq.f47ac10b-58cc-4372-a567-0e02b2c3d479&limit=10

# Get pending tickets
GET /rest/v1/tickets?select=*&status=eq.pending&order=created_at.desc
```

**Response (200 OK):**
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "user_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "title": "Login tidak bisa",
    "description": "Saya tidak bisa login ke aplikasi",
    "status": "pending",
    "assigned_to": null,
    "created_at": "2024-01-15T10:30:00+00:00",
    "updated_at": null
  },
  ...
]
```

**Dart Implementation:**
```dart
Future<List<TicketModel>> getTickets({
  String? userId,
  String? role,
}) async {
  var query = supabaseClient.from('tickets').select();
  
  if (role == 'user' && userId != null) {
    query = query.eq('user_id', userId);
  }
  
  final response = await query.order('created_at', ascending: false);
  
  return (response as List)
    .map((json) => TicketModel.fromJson(json))
    .toList();
}
```

#### 3. Get Ticket Detail (FR-006)
**GET** `/rest/v1/tickets?id=eq.[TICKET_ID]&select=*`

**Response (200 OK):**
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "user_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "title": "Login tidak bisa",
    "description": "Saya tidak bisa login ke aplikasi",
    "status": "pending",
    "assigned_to": null,
    "created_at": "2024-01-15T10:30:00+00:00",
    "updated_at": null
  }
]
```

**Dart Implementation:**
```dart
Future<TicketModel?> getTicketById({required String ticketId}) async {
  final response = await supabaseClient
    .from('tickets')
    .select()
    .eq('id', ticketId)
    .maybeSingle();
  
  if (response == null) return null;
  return TicketModel.fromJson(response);
}
```

#### 4. Update Ticket Status (FR-006.3)
**PATCH** `/rest/v1/tickets?id=eq.[TICKET_ID]`

**Request Body:**
```json
{
  "status": "on_progress",
  "updated_at": "2024-01-15T14:30:00+00:00"
}
```

**Response (200 OK):**
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "status": "on_progress",
    "updated_at": "2024-01-15T14:30:00+00:00",
    ...
  }
]
```

**Dart Implementation:**
```dart
Future<bool> updateTicketStatus({
  required String ticketId,
  required String newStatus,
}) async {
  await supabaseClient
    .from('tickets')
    .update({
      'status': newStatus,
      'updated_at': DateTime.now().toIso8601String(),
    })
    .eq('id', ticketId);
  
  // Also log to history
  await supabaseClient.from('ticket_history').insert({
    'ticket_id': ticketId,
    'user_id': supabaseClient.auth.currentUser!.id,
    'action': 'Status Update',
    'message': 'Status diubah menjadi $newStatus',
    'status': newStatus,
    'created_at': DateTime.now().toIso8601String(),
  });
  
  return true;
}
```

#### 5. Assign Ticket (FR-006.4)
**PATCH** `/rest/v1/tickets?id=eq.[TICKET_ID]`

**Request Body:**
```json
{
  "assigned_to": "f47ac10b-58cc-4372-a567-0e02b2c3d480",
  "updated_at": "2024-01-15T14:35:00+00:00"
}
```

**Dart Implementation:**
```dart
Future<bool> assignTicket({
  required String ticketId,
  required String assignedTo,
}) async {
  await supabaseClient
    .from('tickets')
    .update({
      'assigned_to': assignedTo,
      'updated_at': DateTime.now().toIso8601String(),
    })
    .eq('id', ticketId);
  
  // Log to history
  await supabaseClient.from('ticket_history').insert({
    'ticket_id': ticketId,
    'user_id': supabaseClient.auth.currentUser!.id,
    'action': 'Assigned',
    'message': 'Tiket ditugaskan ke $assignedTo',
    'created_at': DateTime.now().toIso8601String(),
  });
  
  return true;
}
```

#### 6. Delete Ticket
**DELETE** `/rest/v1/tickets?id=eq.[TICKET_ID]`

**Response (204 No Content)**

**Dart Implementation:**
```dart
Future<bool> deleteTicket({required String ticketId}) async {
  await supabaseClient
    .from('tickets')
    .delete()
    .eq('id', ticketId);
  
  return true;
}
```

### Ticket History

#### 1. Add Comment (FR-007)
**POST** `/rest/v1/ticket_history`

**Request Body:**
```json
{
  "ticket_id": "550e8400-e29b-41d4-a716-446655440000",
  "user_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "action": "Comment",
  "message": "Sudah dicoba restart aplikasi?",
  "created_at": "2024-01-15T14:40:00+00:00"
}
```

**Response (201 Created):**
```json
{
  "id": "660e8400-e29b-41d4-a716-446655440001",
  "ticket_id": "550e8400-e29b-41d4-a716-446655440000",
  "user_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "action": "Comment",
  "message": "Sudah dicoba restart aplikasi?",
  "status": null,
  "created_at": "2024-01-15T14:40:00+00:00"
}
```

**Dart Implementation:**
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

#### 2. Get Ticket History (FR-010)
**GET** `/rest/v1/ticket_history?ticket_id=eq.[TICKET_ID]&order=created_at.desc`

**Response (200 OK):**
```json
[
  {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "ticket_id": "550e8400-e29b-41d4-a716-446655440000",
    "user_id": "f47ac10b-58cc-4372-a567-0e02b2c3d480",
    "action": "Status Update",
    "message": "Status diubah menjadi on_progress",
    "status": "on_progress",
    "created_at": "2024-01-15T14:30:00+00:00"
  },
  {
    "id": "660e8400-e29b-41d4-a716-446655440002",
    "ticket_id": "550e8400-e29b-41d4-a716-446655440000",
    "user_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "action": "Comment",
    "message": "Terima kasih sudah dibantu",
    "status": null,
    "created_at": "2024-01-15T14:40:00+00:00"
  }
]
```

### Statistics

#### Get Ticket Statistics (FR-011)
**GET** `/rest/v1/tickets?select=status&user_id=eq.[USER_ID]`

**Response (200 OK):**
```json
[
  { "status": "pending" },
  { "status": "on_progress" },
  { "status": "resolved" },
  { "status": "pending" },
  ...
]
```

**Dart Implementation:**
```dart
Future<Map<String, int>> getTicketStatistics({String? userId}) async {
  var query = supabaseClient.from('tickets').select('status');
  
  if (userId != null) {
    query = query.eq('user_id', userId);
  }
  
  final response = await query;
  
  int total = 0, pending = 0, onProgress = 0, resolved = 0;
  
  for (var item in response as List) {
    total++;
    final status = item['status'] as String?;
    if (status == 'pending') {
      pending++;
    } else if (status == 'on_progress') {
      onProgress++;
    } else if (status == 'resolved') {
      resolved++;
    }
  }
  
  return {
    'total': total,
    'pending': pending,
    'on_progress': onProgress,
    'resolved': resolved,
  };
}
```

### Storage (File Attachments)

#### Upload Attachment (FR-005.2)
**POST** `/storage/v1/object/ticket-attachments/[FILE_PATH]`

**Headers:**
```
Authorization: Bearer [ACCESS_TOKEN]
Content-Type: application/octet-stream
```

**Body:** Binary file data

**Response (200 OK):**
```json
{
  "name": "screenshot.png",
  "id": "...",
  "updated_at": "2024-01-15T14:42:00Z",
  "created_at": "2024-01-15T14:42:00Z",
  "last_accessed_at": "2024-01-15T14:42:00Z",
  "metadata": {
    "eTag": "...",
    "mimetype": "image/png",
    "cacheControl": "max-age=3600",
    "contentLength": 245632
  }
}
```

**Dart Implementation:**
```dart
Future<String> uploadTicketAttachment({
  required String ticketId,
  required List<int> fileBytes,
  required String fileName,
}) async {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final filePath = 'tickets/$ticketId/$timestamp-$fileName';
  
  await supabaseClient.storage
    .from('ticket-attachments')
    .uploadBinary(filePath, fileBytes);
  
  final publicUrl = supabaseClient.storage
    .from('ticket-attachments')
    .getPublicUrl(filePath);
  
  return publicUrl;
}
```

## Error Codes

| Code | Status | Description |
|------|--------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created |
| 204 | No Content | Request successful, no content returned |
| 400 | Bad Request | Invalid request parameters |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Not authorized for this action |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Resource already exists |
| 500 | Server Error | Internal server error |

## Rate Limiting

Default rate limits per minute:
- **Authenticated requests**: 300 requests/min
- **Anonymous requests**: 10 requests/min

## Pagination

### Example: Get first 10 tickets
```dart
final response = await supabaseClient
  .from('tickets')
  .select()
  .range(0, 9)  // offset, limit
  .order('created_at', ascending: false);
```

### Example: Get next page
```dart
final page = 2;
final limit = 10;
final offset = (page - 1) * limit;

final response = await supabaseClient
  .from('tickets')
  .select()
  .range(offset, offset + limit - 1)
  .order('created_at', ascending: false);
```

## Filtering

### Equal
```dart
query.eq('status', 'pending')
```

### In List
```dart
query.inFilter('status', ['pending', 'on_progress'])
```

### Greater Than
```dart
query.gt('created_at', '2024-01-15T00:00:00')
```

### Less Than
```dart
query.lt('created_at', '2024-01-15T23:59:59')
```

## Real-time Subscriptions (Future)

```dart
final subscription = supabaseClient
  .from('tickets')
  .stream(primaryKey: ['id'])
  .listen((List<Map> data) {
    print('Tickets updated: $data');
  });

// Clean up
subscription.cancel();
```

## Best Practices

1. **Always use parameterized queries** untuk avoid SQL injection
2. **Implement pagination** untuk large datasets
3. **Cache responses** di client untuk reduce API calls
4. **Use proper error handling** dengan try-catch
5. **Validate input** di client dan server
6. **Use RLS policies** untuk enforce authorization
7. **Monitor rate limits** dan implement retry logic
8. **Use indexes** untuk frequently filtered columns

