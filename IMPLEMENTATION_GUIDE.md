# E-Ticketing Helpdesk - Implementation Guide

## Prerequisites

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android SDK / Xcode (for mobile)
- VS Code / Android Studio
- Supabase account

## Step 1: Project Setup

### 1.1 Create Flutter Project
```bash
flutter create e_ticketing_helpdesk
cd e_ticketing_helpdesk
```

### 1.2 Update pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.0
  equatable: ^2.0.5
  
  # Dependency Injection
  get_it: ^7.5.0
  
  # Supabase
  supabase_flutter: ^1.10.0
  
  # UI
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  flutter_lints: ^2.0.0
  bloc_test: ^9.0.0
```

### 1.3 Install Dependencies
```bash
flutter pub get
```

## Step 2: Project Structure

Create the following directory structure:
```
lib/
├── features/
│   └── ticket/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       ├── presentation/
│       │   ├── bloc/
│       │   ├── screens/
│       │   └── widgets/
│       ├── routes/
│       ├── injection_container.dart
│       └── README.md
├── config/
│   └── supabase_config.dart
├── core/
│   └── errors/
├── main.dart
└── app.dart
```

## Step 3: Supabase Setup

### 3.1 Create Supabase Project
1. Go to https://supabase.com
2. Create new project
3. Get your `Project URL` and `Anon Key`

### 3.2 Create Database Tables

**SQL Script:**
```sql
-- Create tables
CREATE TABLE tickets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  status VARCHAR(50) DEFAULT 'pending',
  assigned_to UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE ticket_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  action VARCHAR(100) NOT NULL,
  message TEXT NOT NULL,
  status VARCHAR(50),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE ticket_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  file_name VARCHAR(255) NOT NULL,
  file_path VARCHAR(255) NOT NULL,
  file_size INT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_tickets_user_id ON tickets(user_id);
CREATE INDEX idx_tickets_status ON tickets(status);
CREATE INDEX idx_ticket_history_ticket_id ON ticket_history(ticket_id);
CREATE INDEX idx_ticket_history_user_id ON ticket_history(user_id);

-- Enable RLS
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_attachments ENABLE ROW LEVEL SECURITY;
```

### 3.3 Enable Authentication
1. Go to Authentication Settings
2. Enable Email/Password
3. Enable Email confirmation (optional)

### 3.4 Set Up Row Level Security (RLS) Policies

```sql
-- Policies for tickets table
CREATE POLICY "Users can view own tickets" 
  ON tickets FOR SELECT 
  USING (auth.uid() = user_id OR 
         EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' IN ('admin', 'helpdesk')));

CREATE POLICY "Users can create tickets" 
  ON tickets FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admin/Helpdesk can update tickets" 
  ON tickets FOR UPDATE 
  USING (EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' IN ('admin', 'helpdesk')))
  WITH CHECK (EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' IN ('admin', 'helpdesk')));

-- Policies for ticket_history
CREATE POLICY "View ticket history" 
  ON ticket_history FOR SELECT 
  USING (EXISTS (SELECT 1 FROM tickets WHERE id = ticket_id AND (auth.uid() = user_id OR EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' IN ('admin', 'helpdesk')))));
```

### 3.5 Create Storage Bucket
1. Go to Storage
2. Create bucket: `ticket-attachments`
3. Set permissions to allow authenticated users

## Step 4: Implement Core Files

### 4.1 Supabase Configuration
```dart
// lib/config/supabase_config.dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_ANON_KEY';
}
```

### 4.2 Entity Classes
Create `ticket_entity.dart` in `domain/entities/`

### 4.3 Model Classes
Create `ticket_model.dart` in `data/models/`

### 4.4 Data Source
Create `ticket_remote_datasource.dart` in `data/datasources/`

### 4.5 Repository
Create `ticket_repository_impl.dart` in `data/repositories/`

### 4.6 Use Cases
Create `ticket_usecases.dart` in `domain/usecases/`

### 4.7 BLoC
Create `ticket_bloc.dart` in `presentation/bloc/`

### 4.8 Screens
Create screens in `presentation/screens/`:
- `ticket_list_screen.dart`
- `create_ticket_screen.dart`
- `ticket_detail_screen.dart`
- `dashboard_screen.dart`

## Step 5: Main Application Setup

### 5.1 Create App Widget
```dart
// lib/app.dart
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Ticketing Helpdesk',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DashboardScreen(),
      routes: TicketRoutes.getRoutes(context),
      onGenerateRoute: (settings) => null, // Use named routes
    );
  }
}
```

### 5.2 Create Main Entry Point
```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Setup Dependency Injection
  setupTicketDependencies();

  runApp(const MyApp());
}
```

## Step 6: Authentication Integration

### 6.1 Authentication Service
```dart
// Create lib/features/auth/auth_service.dart
class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  Future<void> signUp(String email, String password) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'role': 'user'}, // Default role
    );
  }

  Future<void> signIn(String email, String password) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? getCurrentUser() => _supabase.auth.currentUser;

  String? getUserRole() {
    return getCurrentUser()?.userMetadata?['role'] as String?;
  }
}
```

## Step 7: Error Handling

### 7.1 Custom Exceptions
```dart
// lib/core/errors/exceptions.dart
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}
```

## Step 8: Testing

### 8.1 Unit Tests
```bash
flutter test test/features/ticket/domain/usecases/
```

### 8.2 Integration Tests
```bash
flutter test integration_test/
```

### 8.3 Widget Tests
```bash
flutter test test/features/ticket/presentation/bloc/
```

## Step 9: Build & Deployment

### 9.1 Build APK (Android)
```bash
flutter build apk --release
```

### 9.2 Build AAB (Google Play)
```bash
flutter build appbundle --release
```

### 9.3 Build iOS
```bash
flutter build ios --release
```

## Configuration Checklist

- [ ] Supabase project created
- [ ] Database tables created
- [ ] RLS policies configured
- [ ] Storage bucket created
- [ ] Dependencies installed
- [ ] Entity classes implemented
- [ ] Model classes implemented
- [ ] Data source implemented
- [ ] Repository implemented
- [ ] Use cases implemented
- [ ] BLoC implemented
- [ ] Screens implemented
- [ ] Routes configured
- [ ] Dependency injection setup
- [ ] Authentication integrated
- [ ] Error handling implemented
- [ ] Tests written
- [ ] App tested on device

## Troubleshooting

### Issue: Supabase connection fails
**Solution**: Check URL and Anon Key are correct in `supabase_config.dart`

### Issue: RLS policies blocking operations
**Solution**: Verify policies are correct and user role is set properly

### Issue: BLoC not updating UI
**Solution**: Ensure BLoC is provided in BlocProvider and listener/builder are correct

### Issue: Model parsing errors
**Solution**: Check JSON field names match Supabase column names

## Next Steps

1. Implement authentication UI (login/signup screens)
2. Add advanced filtering and search
3. Implement real-time updates with subscriptions
4. Add offline support with local caching
5. Implement push notifications
6. Create admin panel
7. Add analytics

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Flutter BLoC Documentation](https://bloclibrary.dev)
- [Clean Architecture Guide](https://resocoder.com/flutter-clean-architecture)

