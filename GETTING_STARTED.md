# E-Ticketing Helpdesk - Getting Started Guide

## 🎯 Quick Start (5 Minutes)

Panduan cepat untuk memulai development dengan E-Ticketing Helpdesk.

---

## Step 1: Understand the Project Structure

```
e_ticketing_helpdesk/
├── lib/
│   └── features/ticket/
│       ├── data/          ← Data layer (Supabase API calls)
│       ├── domain/        ← Business logic (Use cases)
│       ├── presentation/  ← UI & BLoC (Screens)
│       └── routes/        ← Navigation setup
├── docs/
│   ├── ARCHITECTURE.md         ← How the project is structured
│   ├── IMPLEMENTATION_GUIDE.md ← Step-by-step setup
│   ├── DATABASE_SCHEMA.md      ← Database design
│   ├── API_GUIDE.md            ← API endpoints
│   ├── FEATURE_REQUIREMENTS.md ← Feature details
│   └── PROJECT_SUMMARY.md      ← Complete overview
└── README.md              ← Project overview
```

---

## Step 2: Review Key Concepts

### Clean Architecture Layers
```
┌─────────────────────────┐
│   PRESENTATION LAYER    │ ← Screens, BLoC, UI
├─────────────────────────┤
│     DOMAIN LAYER        │ ← Use Cases, Entities
├─────────────────────────┤
│      DATA LAYER         │ ← Models, DataSources
├─────────────────────────┤
│   External (Supabase)   │ ← Database, Auth, Storage
└─────────────────────────┘
```

### Data Flow Example
```
User clicks "Create Ticket"
    ↓
CreateTicketScreen triggers CreateTicketEvent
    ↓
TicketBloc receives event
    ↓
Calls CreateTicketUseCase.call()
    ↓
Use case calls repository.createTicket()
    ↓
Repository calls dataSource.createTicket()
    ↓
DataSource makes Supabase API call
    ↓
Response converted to TicketModel
    ↓
BLoC emits TicketSuccess state
    ↓
Screen rebuilds and shows success dialog
```

---

## Step 3: Understand Key Files

### Core Implementation Files

#### 1. **ticket_entity.dart** (Domain)
- Defines `TicketEntity` - pure business object
- No dependencies on frameworks
- Used throughout the app

```dart
class TicketEntity {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String status; // 'pending', 'on_progress', 'resolved'
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime? updatedAt;
}
```

#### 2. **ticket_model.dart** (Data)
- Extends TicketEntity for Supabase
- Handles JSON serialization
- Conversion between layers

```dart
class TicketModel extends TicketEntity {
  // JSON → Model conversion
  factory TicketModel.fromJson(Map<String, dynamic> json) { ... }
  
  // Model → JSON conversion
  Map<String, dynamic> toJson() { ... }
}
```

#### 3. **ticket_repository.dart** (Domain Interface)
- Defines contract for data operations
- Implementation-agnostic
- Language of business

```dart
abstract class TicketRepository {
  Future<TicketEntity> createTicket({...});
  Future<List<TicketEntity>> getTickets({...});
  Future<bool> updateTicketStatus({...});
  // ... other operations
}
```

#### 4. **ticket_remote_datasource.dart** (Data)
- Actual Supabase API calls
- HTTP communication
- Error handling from API

```dart
class TicketRemoteDataSourceImpl implements TicketRemoteDataSource {
  Future<TicketModel> createTicket({...}) async {
    // Call Supabase
    final response = await supabaseClient
      .from('tickets')
      .insert({...})
      .select()
      .single();
    
    return TicketModel.fromJson(response);
  }
}
```

#### 5. **ticket_usecases.dart** (Domain)
- Business logic for each operation
- Orchestrates between entities and repository
- One class per use case

```dart
class CreateTicketUseCase {
  final TicketRepository repository;
  
  Future<TicketEntity> call({
    required String title,
    required String description,
  }) async {
    return await repository.createTicket(
      title: title,
      description: description,
    );
  }
}
```

#### 6. **ticket_bloc.dart** (Presentation)
- Manages state for screens
- Receives events from UI
- Emits states for UI to rebuild

```dart
class TicketBloc extends Bloc<TicketEvent, TicketState> {
  // Event handlers
  on<FetchTicketsEvent>(_onFetchTickets);
  on<CreateTicketEvent>(_onCreateTicket);
  // ...
  
  // Each handler calls use case
  _onCreateTicket(CreateTicketEvent event, emit) {
    await createTicketUseCase.call(...);
    emit(TicketSuccess());
  }
}
```

#### 7. **Screens** (Presentation)
- UI implementation
- Display data from BLoC state
- Send events from user actions

```dart
class CreateTicketScreen extends StatefulWidget {
  // Form inputs
  final titleController = TextEditingController();
  
  // Submit handler
  _submitForm() {
    context.read<TicketBloc>().add(
      CreateTicketEvent(
        title: titleController.text,
        description: descriptionController.text,
      ),
    );
  }
  
  // Listen to state
  BlocListener<TicketBloc, TicketState>(
    listener: (context, state) {
      if (state is TicketSuccess) {
        showSuccessDialog();
      }
    },
  );
}
```

---

## Step 4: Understanding Roles & Permissions

### Three User Roles

| Action | User | Helpdesk | Admin |
|--------|------|----------|-------|
| Create ticket | ✅ | ✅ | ✅ |
| View own tickets | ✅ | - | - |
| View all tickets | - | ✅ | ✅ |
| Update status | - | ✅ | ✅ |
| Assign ticket | - | ✅ | ✅ |
| Delete ticket | - | - | ✅ |

### Implementation in DataSource
```dart
Future<List<TicketModel>> getTickets({
  String? userId,
  String? role,
}) async {
  var query = supabaseClient.from('tickets').select();
  
  // Role-based filtering
  if (role == 'user' && userId != null) {
    query = query.eq('user_id', userId); // Only own
  }
  // Admin/Helpdesk see all
  
  return await query.order('created_at', ascending: false);
}
```

---

## Step 5: Database Understanding

### Three Main Tables

#### tickets
```sql
CREATE TABLE tickets (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,        -- Who created
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  status VARCHAR(50),            -- pending, on_progress, resolved
  assigned_to UUID,              -- Who handles it
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

#### ticket_history
```sql
CREATE TABLE ticket_history (
  id UUID PRIMARY KEY,
  ticket_id UUID NOT NULL,       -- Which ticket
  user_id UUID NOT NULL,         -- Who did action
  action VARCHAR(100),           -- Status Update, Comment, Assigned
  message TEXT,                  -- Details
  created_at TIMESTAMP
);
```

#### Relationships
```
users (1) ←→ (∞) tickets (user_id)
users (1) ←→ (∞) tickets (assigned_to)
tickets (1) ←→ (∞) ticket_history (ticket_id)
```

---

## Step 6: Common Tasks

### Task 1: Create a New Ticket

**User Interaction:**
```
1. Click "Buat Tiket" button
2. Enter title & description
3. Click submit
```

**Code Flow:**
```
CreateTicketScreen
  ↓
User clicks submit → _submitForm()
  ↓
Validate inputs
  ↓
context.read<TicketBloc>().add(CreateTicketEvent(...))
  ↓
TicketBloc._onCreateTicket()
  ↓
createTicketUseCase.call(title, description)
  ↓
repository.createTicket()
  ↓
dataSource.createTicket() [Supabase POST]
  ↓
Response: TicketModel
  ↓
emit(TicketSuccess())
  ↓
BlocListener catches state
  ↓
Show dialog + navigate back
```

### Task 2: View Ticket List

```
FetchTicketsEvent
  ↓
TicketBloc._onFetchTickets()
  ↓
getTicketsUseCase(userId, role)
  ↓
repository.getTickets()
  ↓
dataSource.getTickets() [Supabase GET]
  ↓
List<TicketModel>
  ↓
emit(TicketsLoaded(tickets))
  ↓
BlocBuilder rebuilds
  ↓
Display ListView with TicketCards
```

### Task 3: Update Ticket Status

```
TicketDetailScreen
  ↓
User clicks "Mulai" button
  ↓
context.read<TicketBloc>().add(
  UpdateTicketStatusEvent(ticketId, 'on_progress')
)
  ↓
TicketBloc._onUpdateTicketStatus()
  ↓
updateTicketStatusUseCase(ticketId, newStatus)
  ↓
repository.updateTicketStatus()
  ↓
dataSource.updateTicketStatus() [Supabase PATCH]
  ↓
Also insert to ticket_history for audit
  ↓
emit(TicketSuccess())
  ↓
Refresh detail view
```

---

## Step 7: Debug Common Issues

### Issue: BLoC state not updating
**Check:**
1. Is BLoC provided? `BlocProvider.value(value: getIt<TicketBloc>())`
2. Is listener/builder connected? `BlocBuilder<TicketBloc, TicketState>`
3. Is event added correctly? `context.read<TicketBloc>().add(event)`

### Issue: Supabase connection fails
**Check:**
1. Project URL correct in config
2. Anon key correct
3. Network connectivity
4. Firebase/Supabase server status

### Issue: RLS policy blocking access
**Check:**
1. User authenticated
2. user_id matches
3. Role in user_metadata
4. Policy logic correct

### Issue: JSON parsing error
**Check:**
1. Column names match (snake_case: `user_id`, `created_at`)
2. Types match (String, int, boolean)
3. Null values handled
4. Date format ISO8601

---

## Step 8: Adding New Feature

### To add new feature "Export to PDF":

1. **Create Use Case** (Domain)
```dart
class ExportTicketPdfUseCase {
  final TicketRepository repository;
  
  Future<String> call({required String ticketId}) async {
    // Business logic
  }
}
```

2. **Add to Repository** (Domain)
```dart
abstract class TicketRepository {
  Future<String> exportTicketPdf({required String ticketId});
}
```

3. **Implement in Repository** (Data)
```dart
class TicketRepositoryImpl implements TicketRepository {
  @override
  Future<String> exportTicketPdf({required String ticketId}) async {
    return await remoteDataSource.exportTicketPdf(ticketId);
  }
}
```

4. **Add DataSource Method** (Data)
```dart
Future<String> exportTicketPdf({required String ticketId}) async {
  // Call Supabase function or generate PDF
}
```

5. **Add BLoC Event & State** (Presentation)
```dart
class ExportTicketPdfEvent extends TicketEvent { ... }
class PdfExported extends TicketState { ... }
```

6. **Add BLoC Handler** (Presentation)
```dart
on<ExportTicketPdfEvent>(_onExportTicketPdf);

Future<void> _onExportTicketPdf(
  ExportTicketPdfEvent event,
  Emitter<TicketState> emit,
) async {
  emit(TicketLoading());
  try {
    final url = await exportTicketPdfUseCase(ticketId: event.ticketId);
    emit(PdfExported(url: url));
  } catch (e) {
    emit(TicketError(message: e.toString()));
  }
}
```

7. **Register in DI** (Injection Container)
```dart
getIt.registerSingleton<ExportTicketPdfUseCase>(...);
```

8. **Add UI** (Screens)
```dart
FloatingActionButton(
  onPressed: () {
    context.read<TicketBloc>().add(
      ExportTicketPdfEvent(ticketId: ticketId)
    );
  },
  child: Icon(Icons.download),
)
```

---

## Step 9: Testing

### Unit Test Example
```dart
test('CreateTicketUseCase should return TicketEntity', () async {
  // Arrange
  final mockRepository = MockTicketRepository();
  final useCase = CreateTicketUseCase(repository: mockRepository);
  
  // Act
  final result = await useCase(
    title: 'Test Ticket',
    description: 'Test Description',
  );
  
  // Assert
  expect(result, isA<TicketEntity>());
});
```

### Widget Test Example
```dart
testWidgets('CreateTicketScreen shows form', (tester) async {
  // Arrange
  await tester.pumpWidget(
    BlocProvider<TicketBloc>(
      create: (_) => mockTicketBloc,
      child: MaterialApp(home: CreateTicketScreen()),
    ),
  );
  
  // Assert
  expect(find.byType(TextFormField), findsWidgets);
  expect(find.byType(ElevatedButton), findsOneWidget);
});
```

---

## Step 10: Deployment Checklist

- [ ] All environment variables set
- [ ] Supabase RLS policies enabled
- [ ] Database backups configured
- [ ] API error handling complete
- [ ] Input validation added
- [ ] UI tested on multiple devices
- [ ] Screens responsive
- [ ] Tests passing
- [ ] No hardcoded secrets
- [ ] Documentation updated

---

## 📚 Next Steps

1. **Read ARCHITECTURE.md** - Understand design patterns
2. **Follow IMPLEMENTATION_GUIDE.md** - Set up Supabase
3. **Study FEATURE_REQUIREMENTS.md** - Learn each feature
4. **Review DATABASE_SCHEMA.md** - Understand data model
5. **Check API_GUIDE.md** - Learn API endpoints

---

## 💡 Tips & Best Practices

1. **Always validate input** - UI and server
2. **Use proper error handling** - Don't show technical errors
3. **Keep use cases small** - One responsibility
4. **Use dependency injection** - Don't instantiate directly
5. **Test edge cases** - Null, empty, errors
6. **Document as you code** - Future self will thank you
7. **Follow naming conventions** - snake_case for columns, camelCase for dart
8. **Use strong typing** - Avoid dynamic
9. **Handle async properly** - Use async/await
10. **Security first** - RLS, validation, HTTPS

---

## 🤝 Need Help?

- Read documentation in `docs/` folder
- Check code comments in implementation files
- Look at screen examples for UI patterns
- Review use cases for business logic patterns
- Check database schema for data structure

---

**Happy coding!** 🚀

