# E-Ticketing Helpdesk - Mobile Application

Aplikasi mobile Flutter untuk mengelola tiket support/helpdesk dengan fitur role-based access control dan real-time updates.

## 🎯 Fitur Utama

### FR-001: Sistem Autentikasi
- ✅ Login/Signup dengan email dan password
- ✅ Forgot password functionality
- ✅ Session management
- ✅ Role-based access control (User, Helpdesk, Admin)

### FR-005: Membuat Tiket
- ✅ Form untuk membuat tiket baru
- ✅ Validasi input
- ✅ Support file attachment
- ✅ Auto-save to database

### FR-006: Menampilkan Daftar Tiket
- ✅ View tiket berdasarkan role
- ✅ Filter by status (pending, on_progress, resolved)
- ✅ Search dan sorting
- ✅ Pagination support
- ✅ Refresh functionality

### FR-006.3 & FR-006.4: Update Status & Assign
- ✅ Update status tiket (pending → on_progress → resolved)
- ✅ Assign tiket ke helpdesk staff
- ✅ Validation before update
- ✅ History logging

### FR-007: Tambah Komentar
- ✅ Add comments ke tiket
- ✅ View komentar history
- ✅ Real-time update (future)

### FR-010: Riwayat Tiket
- ✅ View complete ticket history
- ✅ Audit trail for all changes
- ✅ Status tracking
- ✅ Comment threads

### FR-011: Dashboard & Statistics
- ✅ Dashboard overview
- ✅ Ticket statistics
- ✅ Status distribution chart
- ✅ Quick actions

### FR-005.2: File Attachment
- ✅ Upload files ke tiket
- ✅ Secure file storage (Supabase)
- ✅ File preview
- ✅ Download support (future)

## 🏗️ Tech Stack

### Frontend
- **Flutter** 3.0+ - UI Framework
- **Dart** 3.0+ - Programming Language
- **Flutter BLoC** - State Management
- **Equatable** - Value Equality

### Backend
- **Supabase** - Backend as a Service
- **PostgreSQL** - Database
- **Supabase Auth** - Authentication
- **Supabase Storage** - File Storage

### Architecture
- **Clean Architecture** - Separation of concerns
- **SOLID Principles** - Maintainable code
- **Repository Pattern** - Data abstraction
- **Use Case Pattern** - Business logic

## 📁 Project Structure

```
lib/features/ticket/
├── data/
│   ├── datasources/
│   │   └── ticket_remote_datasource.dart
│   ├── models/
│   │   └── ticket_model.dart
│   └── repositories/
│       └── ticket_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── ticket_entity.dart
│   ├── repositories/
│   │   └── ticket_repository.dart
│   └── usecases/
│       └── ticket_usecases.dart
├── presentation/
│   ├── bloc/
│   │   └── ticket_bloc.dart
│   ├── screens/
│   │   ├── dashboard_screen.dart
│   │   ├── ticket_list_screen.dart
│   │   ├── create_ticket_screen.dart
│   │   └── ticket_detail_screen.dart
│   └── widgets/
├── routes/
│   └── ticket_routes.dart
└── injection_container.dart
```

## 🚀 Quick Start

### Prerequisites
- Flutter 3.0+
- Dart 3.0+
- Supabase account
- Git

### Installation

1. **Clone Repository**
```bash
git clone <repository-url>
cd e_ticketing_helpdesk
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Setup Supabase**
   - Create project at https://supabase.com
   - Copy project URL dan anon key
   - Update `lib/config/supabase_config.dart`

4. **Create Database**
   - Run SQL migrations from `DATABASE_SCHEMA.md`
   - Enable RLS policies
   - Create storage bucket

5. **Run Application**
```bash
flutter run
```

## 📚 Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Clean Architecture explanation
- **[IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)** - Step-by-step implementation
- **[DATABASE_SCHEMA.md](DATABASE_SCHEMA.md)** - Database design dan RLS policies
- **[API_GUIDE.md](API_GUIDE.md)** - REST API endpoints

## 🔐 Authentication & Authorization

### Roles & Permissions

| Feature | User | Helpdesk | Admin |
|---------|------|----------|-------|
| Create Ticket | ✅ | ✅ | ✅ |
| View Own Tickets | ✅ | - | - |
| View All Tickets | - | ✅ | ✅ |
| Update Status | - | ✅ | ✅ |
| Assign Ticket | - | ✅ | ✅ |
| View Statistics | ✅ | ✅ | ✅ |
| Delete Ticket | - | - | ✅ |

## 📊 States Management

Using **Flutter BLoC** for state management with proper separation of concerns.

## 🧪 Testing

```bash
# Unit tests
flutter test test/features/ticket/domain/

# Widget tests
flutter test test/features/ticket/presentation/

# Integration tests
flutter test integration_test/
```

## 🚀 Build & Deployment

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 🔒 Security

- ✅ Secure authentication dengan Supabase Auth
- ✅ Row Level Security (RLS) di database
- ✅ Input validation
- ✅ HTTPS for all API calls

## 📞 Support

For support, open an issue in the repository.

---

**Version**: 1.0.0
**Last Updated**: January 2024
