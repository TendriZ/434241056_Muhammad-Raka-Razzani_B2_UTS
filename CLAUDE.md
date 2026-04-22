# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

E-Ticketing Helpdesk is a Flutter mobile application for managing support/helpdesk tickets with role-based access control. It uses **Clean Architecture** with BLoC pattern for state management and integrates with Supabase for backend services.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run the application
flutter run

# Run on specific device
flutter run -d <device_id>

# Analyze code
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage

# Build release APK
flutter build apk --release

# Build iOS release
flutter build ios --release

# Build web
flutter build web --release

# Clean build artifacts
flutter clean

# Format code
dart format .
```

## High-Level Architecture

### Clean Architecture Layers

The project follows **Clean Architecture** with three main layers:

```
┌─────────────────────────┐
│   PRESENTATION LAYER    │ ← UI, BLoC (flutter_bloc), Riverpod providers
├─────────────────────────┤
│     DOMAIN LAYER        │ ← Use Cases, Entities (pure Dart)
├─────────────────────────┤
│      DATA LAYER         │ ← Models, DataSources (Supabase integration)
├─────────────────────────┤
│   External (Supabase)   │ ← Auth, PostgreSQL, Storage
└─────────────────────────┘
```

### State Management Dual Approach

The project uses **two state management solutions** for different purposes:

1. **Flutter BLoC** - Used within the Ticket feature for complex state logic
   - Located in: `lib/features/ticket/presentation/bloc/`
   - Pattern: Events trigger state changes that rebuild UI

2. **Riverpod** - Used for app-wide concerns (routing, theme, auth)
   - Located in: `lib/core/services/app_router.dart`, `lib/core/theme/theme_provider.dart`
   - Pattern: Providers expose state that widgets watch

### Dependency Injection

Uses **GetIt** for service location:
- Setup in: `lib/features/ticket/injection_container.dart`
- Registration order: DataSource → Repository → UseCase → BLoC
- Note: Only the Ticket feature has DI setup; other features use Riverpod providers directly

### Data Flow Pattern

```
UI (Screen)
  ↓ add event
BLoC/Riverpod
  ↓ call
Use Case
  ↓ call
Repository (interface)
  ↓ call
DataSource (Supabase)
  ↓ HTTP
Supabase
  ↓ response
Model
  ↓ convert
Entity
  ↓ emit
State
  ↓ rebuild
UI updated
```

### Role-Based Access Control

Three user roles with different permissions:

| Feature | User | Helpdesk | Admin |
|---------|------|----------|-------|
| Create Ticket | ✅ | ✅ | ✅ |
| View Own Tickets | ✅ | - | - |
| View All Tickets | - | ✅ | ✅ |
| Update Status | - | ✅ | ✅ |
| Assign Ticket | - | ✅ | ✅ |
| Delete Ticket | - | - | ✅ |

Role filtering is implemented in DataSource methods (e.g., `TicketRemoteDataSource.getTickets()`) where regular users only see their own tickets via `user_id` filtering.

### Key File Relationships

**Entry Point**: `lib/main.dart`
- Initializes Supabase
- Calls `setupTicketDependencies()` for DI
- Wraps app in Riverpod's `ProviderScope`

**Routing**: `lib/core/services/app_router.dart`
- Uses GoRouter (via Riverpod)
- Handles navigation between features
- Guards routes based on auth state

**Feature Structure** (using ticket as the reference implementation):
```
lib/features/ticket/
├── data/
│   ├── datasources/ticket_remote_datasource.dart  # Supabase API calls
│   ├── models/ticket_model.dart                   # JSON serialization
│   └── repositories/ticket_repository_impl.dart   # Repository implementation
├── domain/
│   ├── entities/ticket_entity.dart                # Pure business objects
│   ├── repositories/ticket_repository.dart        # Interface
│   └── usecases/ticket_usecases.dart              # Business logic per operation
├── presentation/
│   ├── bloc/ticket_bloc.dart                      # State management
│   ├── pages/                                     # UI screens
│   └── providers/                                 # Riverpod providers (if any)
├── routes/ticket_routes.dart                      # Feature routing
└── injection_container.dart                       # DI registration
```

### Supabase Integration

- **Auth**: Handled via `supabase_flutter` package
- **Tables**: `tickets`, `ticket_history`, `ticket_attachments`
- **Storage**: File attachments stored in Supabase Storage
- **RLS**: Row Level Security policies enforce role-based access

Configuration is hardcoded in `lib/main.dart` (supabaseUrl, supabaseAnonKey) - this is a student project and not a production secret concern.

### Testing Strategy

- **Unit tests**: Test domain layer (UseCases) with mocked repositories
- **Widget tests**: Test presentation layer with mocked BLoCs
- **Integration tests**: Test data layer with real Supabase (staging)

Test directory structure follows the same feature organization as `lib/`.
