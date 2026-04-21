# E-Ticketing Helpdesk - Architecture Documentation

## Overview

E-Ticketing Helpdesk adalah aplikasi mobile Flutter untuk mengelola tiket support/helpdesk dengan fitur role-based access control. Aplikasi ini menggunakan **Clean Architecture** untuk memastikan maintainability, testability, dan scalability.

## Architecture Layers

### 1. Presentation Layer (UI & State Management)
Bertanggung jawab untuk menampilkan UI dan mengelola state aplikasi.

**Struktur:**
```
lib/features/ticket/presentation/
├── bloc/
│   └── ticket_bloc.dart        # BLoC untuk state management
├── screens/
│   ├── ticket_list_screen.dart        # List tiket (FR-006)
│   ├── create_ticket_screen.dart      # Buat tiket (FR-005)
│   ├── ticket_detail_screen.dart      # Detail tiket (FR-006, FR-007)
│   └── dashboard_screen.dart          # Dashboard (FR-011)
└── widgets/
    └── # Reusable widgets
```

**Teknologi:**
- **Flutter BLoC**: State management
- **Equatable**: Equality untuk events dan states

**Events & States:**
```dart
// Events
FetchTicketsEvent, FetchTicketDetailEvent, CreateTicketEvent, 
UpdateTicketStatusEvent, AssignTicketEvent, AddTicketCommentEvent,
FetchTicketHistoryEvent, FetchTicketStatisticsEvent, 
UploadTicketAttachmentEvent, DeleteTicketEvent

// States
TicketInitial, TicketLoading, TicketSuccess,
TicketsLoaded, TicketDetailLoaded, TicketHistoryLoaded,
TicketStatisticsLoaded, TicketError
```

### 2. Domain Layer (Business Logic)
Mendefinisikan business rules dan use cases.

**Struktur:**
```
lib/features/ticket/domain/
├── entities/
│   └── ticket_entity.dart      # Domain entities (pure business objects)
├── repositories/
│   └── ticket_repository.dart  # Repository interface
└── usecases/
    └── ticket_usecases.dart    # Business logic use cases
```

**Entities:**
- `TicketEntity`: Representasi abstrak tiket
- `TicketHistoryEntity`: Representasi abstrak history

**Use Cases:**
```dart
CreateTicketUseCase            // FR-005: Membuat tiket
GetTicketsUseCase              // FR-006: Mengambil daftar tiket
GetTicketDetailUseCase         // FR-006: Mengambil detail tiket
UpdateTicketStatusUseCase      // FR-006.3: Update status
AssignTicketUseCase            // FR-006.4: Assign tiket
AddTicketCommentUseCase        // FR-007: Menambah komentar
GetTicketHistoryUseCase        // FR-010: Mengambil history
GetTicketStatisticsUseCase     // FR-011: Statistik tiket
UploadTicketAttachmentUseCase  // FR-005.2: Upload file
DeleteTicketUseCase            // Menghapus tiket
```

### 3. Data Layer (Data Access)
Menangani komunikasi dengan backend dan caching.

**Struktur:**
```
lib/features/ticket/data/
├── models/
│   └── ticket_model.dart           # Framework-specific models
├── datasources/
│   └── ticket_remote_datasource.dart   # Remote API calls (Supabase)
└── repositories/
    └── ticket_repository_impl.dart # Repository implementation
```

**Responsibilities:**
- **Models**: Konversi JSON dari/ke Entity
- **DataSources**: Komunikasi dengan Supabase
- **Repository Implementation**: Menggabungkan data dari berbagai sources

## Data Flow

### Contoh: Membuat Tiket (FR-005)

```
UI (CreateTicketScreen)
    ↓ trigger CreateTicketEvent
BLoC (TicketBloc)
    ↓ call
Use Case (CreateTicketUseCase)
    ↓ call
Repository (TicketRepository)
    ↓ call
Data Source (TicketRemoteDataSource)
    ↓ HTTP request
Supabase
    ↓ response
Model (TicketModel)
    ↓ convert to Entity
BLoC emit TicketSuccess state
    ↓ rebuild
UI shows success dialog
```

## Dependency Injection

**Setup in `injection_container.dart`:**
```dart
void setupTicketDependencies() {
  // 1. Register Data Sources
  getIt.registerSingleton<TicketRemoteDataSource>(...)
  
  // 2. Register Repositories
  getIt.registerSingleton<TicketRepository>(...)
  
  // 3. Register Use Cases
  getIt.registerSingleton<CreateTicketUseCase>(...)
  getIt.registerSingleton<GetTicketsUseCase>(...)
  // ... other use cases
  
  // 4. Register BLoC
  getIt.registerSingleton<TicketBloc>(...)
}
```

**Usage:**
```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(...)
  
  // Setup dependencies
  setupTicketDependencies()
  
  runApp(MyApp())
}

// In screens
context.read<TicketBloc>().add(FetchTicketsEvent())
```

## BLoC Pattern

### Event → BLoC → State → UI

```dart
// 1. User triggered event
context.read<TicketBloc>().add(CreateTicketEvent(
  title: 'Bug di halaman login',
  description: 'Tidak bisa login dengan akun tertentu'
))

// 2. BLoC processes event
BLoC receives CreateTicketEvent
    ↓
Calls createTicketUseCase.call(...)
    ↓
Returns TicketEntity or throws Exception

// 3. BLoC emits state
if success: emit(TicketSuccess())
if error: emit(TicketError(message: '...'))

// 4. UI listens and rebuilds
BlocListener rebuilds on TicketSuccess
    ↓
Shows success dialog
```

## Error Handling

**Centralized in Repository & Use Cases:**
```dart
try {
  // Execute business logic
} catch (e) {
  // Domain layer converts technical errors to business errors
  throw Exception('User-friendly message: $e')
}
```

**Displayed in UI:**
```dart
BlocListener<TicketBloc, TicketState>(
  listener: (context, state) {
    if (state is TicketError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message))
      )
    }
  }
)
```

## Role-Based Features

| Role | Features |
|------|----------|
| **User** | Create, View Own, Comment, View Stats |
| **Helpdesk** | View All, Update Status, Assign, Comment |
| **Admin** | Full Access (Create, Read, Update, Delete, Statistics) |

**Implementation in Data Source:**
```dart
Future<List<TicketModel>> getTickets({
  String? userId,
  String? role,
}) async {
  var query = supabaseClient.from('tickets').select();
  
  // Role-based filtering
  if (role == 'user' && userId != null) {
    query = query.eq('user_id', userId);
  }
  // Admin and helpdesk see all
  
  return query.order('created_at', ascending: false);
}
```

## Supabase Integration

### Tables
- `tickets`: Main ticket data
- `ticket_history`: Audit trail and comments
- `ticket_attachments`: File storage

### Authentication
```dart
final user = supabase.auth.currentUser;
final userId = user?.id;
final userEmail = user?.email;
```

### Real-time Subscriptions (Future Enhancement)
```dart
supabase
  .from('tickets')
  .stream(primaryKey: ['id'])
  .listen((List<Map> data) {
    // Update UI with real-time data
  })
```

## Testing Strategy

### Unit Tests (Domain Layer)
- Test Use Cases with mocked Repository
- Verify business logic

### Integration Tests (Data Layer)
- Test Repository with mocked DataSource
- Test DataSource with real Supabase (staging)

### Widget Tests (Presentation Layer)
- Test BLoC events and states
- Test UI rendering with mocked BLoC

## Future Enhancements

1. **Real-time Updates**: WebSocket untuk live status
2. **Offline Support**: Local caching dengan Hive/SQLite
3. **Notifications**: Push notifications untuk status changes
4. **File Attachments**: Enhanced file management
5. **Advanced Filtering**: Filter by priority, category, date range
6. **Export Reports**: PDF dan Excel exports
7. **Analytics**: Detailed statistics dan trends
8. **Multi-language**: i18n support

## Performance Considerations

1. **Lazy Loading**: List tiket di-load dengan pagination
2. **Image Caching**: CachedNetworkImage untuk attachments
3. **BLoC Optimization**: Single BLoC instance shared across screens
4. **State Management**: Hanya rebuild affected widgets

## Security

1. **Authentication**: Supabase Auth
2. **Row Level Security (RLS)**: Database-level access control
3. **Input Validation**: Form validation di UI dan Domain layer
4. **Secure Storage**: Sensitive data di secure storage (tidak hardcoded)

