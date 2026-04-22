# LAPORAN UTS TEORI
## E-Ticketing Helpdesk Mobile Application

---

**Nama:** Muhammad Raka Razzani  
**NIM:** 434241056  
**Kelas:** B2  
**Mata Kuliah:** Mobile Programming Praktikum  
**Dosen Pengampu:** [Nama Dosen]  
**Semester:** 3  
**Tahun Ajaran:** 2025/2026

---

## DAFTAR ISI

1. [Pendahuluan](#1-pendahuluan)
2. [Deskripsi Proyek](#2-deskripsi-proyek)
3. [Palet Warna (Color Palette)](#3-palet-warna-color-palette)
4. [Tipografi dan Font](#4-tipografi-dan-font)
5. [Wireframe Desain](#5-wireframe-desain)
6. [Prototipe Desain](#6-prototipe-desain)
7. [Arsitektur Aplikasi](#7-arsitektur-aplikasi)
8. [Fitur dan Fungsionalitas](#8-fitur-dan-fungsionalitas)
9. [Kesimpulan](#9-kesimpulan)

---

## 1. PENDAHULUAN

### 1.1 Latar Belakang
Dalam era digital saat ini, sistem bantuan teknis (helpdesk) merupakan komponen penting dalam organisasi maupun institusi pendidikan. E-Ticketing Helpdesk adalah solusi mobile yang dikembangkan untuk mempermudah pengelolaan tiket dukungan teknis dengan pendekatan role-based access control. Aplikasi ini memungkinkan tiga jenis pengguna (User/Mahasiswa, Helpdesk, dan Admin) untuk berinteraksi dalam ekosistem tiket yang terstruktur.

### 1.2 Tujuan
- Mengembangkan aplikasi mobile Flutter untuk manajemen tiket helpdesk
- Menerapkan Clean Architecture dalam pengembangan aplikasi
- Mengimplementasikan role-based access control (RBAC)
- Membuat antarmuka pengguna yang intuitif dan responsif

### 1.3 Ruang Lingkup
Aplikasi ini mencakup:
- Sistem autentikasi dengan 3 role (User, Helpdesk, Admin)
- Manajemen tiket lengkap (buat, lihat, update, hapus)
- Upload lampiran file dan gambar
- Dashboard statistik real-time
- Riwayat dan audit trail tiket

---

## 2. DESKRIPSI PROYEK

### 2.1 Nama Aplikasi
**E-Ticketing Helpdesk**

### 2.2 Platform
- **Framework:** Flutter 3.0+
- **Language:** Dart 3.0+
- **Backend:** Supabase (PostgreSQL + Auth + Storage)
- **State Management:** Flutter BLoC + Riverpod
- **Architecture:** Clean Architecture (Domain-Driven Design)

### 2.3 Target Pengguna
| Role | Deskripsi |
|------|-----------|
| **User** | Mahasiswa/pegawai yang membuat tiket bantuan |
| **Helpdesk** | Staff yang menangani dan memproses tiket |
| **Admin** | Administrator dengan akses penuh sistem |

---

## 3. PALET WARNA (COLOR PALETTE)

### 3.1 Primary Colors
Aplikasi menggunakan Material 3 Design dengan seed color Blue:

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| **Primary** | `#2196F3` (Colors.blue) | AppBar, Buttons, Icons utama |
| **Primary Light** | `#64B5F6` (Colors.blue.shade300) | Hover states, gradients |
| **Primary Dark** | `#1976D2` (Colors.blue.shade700) | Pressed states |
| **On Primary** | `#FFFFFF` | Text on primary color |

### 3.2 Secondary Colors
| Color Name | Hex Code | Usage |
|------------|----------|-------|
| **Secondary** | `#FFC107` (Colors.amber) | Accent, highlights (Dark Mode) |
| **Secondary Light** | `#FFD54F` | Chips, badges |
| **On Secondary** | `#000000` | Text on secondary |

### 3.3 Semantic Colors (Status Indicator)
| Status | Color | Hex Code | Usage |
|--------|-------|----------|-------|
| **Pending** | Orange | `#FF9800` | Tiket menunggu |
| **On Progress** | Purple | `#9C27B0` | Tiket diproses |
| **Resolved** | Green | `#4CAF50` | Tiket selesai |
| **Error** | Red | `#F44336` | Error messages |
| **Success** | Green | `#4CAF50` | Success feedback |
| **Info** | Blue | `#2196F3` | Information |

### 3.4 Neutral Colors
| Color Name | Hex Code | Usage |
|------------|----------|-------|
| **Background (Light)** | `#FFFFFF` | Main background |
| **Surface (Light)** | `#F5F5F5` | Cards, dialogs |
| **Background (Dark)** | `#121212` | Dark mode background |
| **Surface (Dark)** | `#1E1E1E` | Dark mode cards |
| **On Surface** | `#212121` | Primary text |
| **Outline** | `#E0E0E0` | Borders, dividers |

### 3.5 Gradient Colors
**Login Page Gradient:**
```dart
colors: [
  Colors.blue.shade50,    // #E3F2FD
  Colors.white,           // #FFFFFF
  Colors.blue.shade100,   // #BBDEFB
]
```

**Stat Card Gradient:**
```dart
gradient: LinearGradient(
  colors: [
    color.withValues(alpha: 0.1),      // 10% opacity primary
    Colors.white.withValues(alpha: 0.05),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### 3.6 Color Implementation in Code

**File:** `lib/main.dart`
```dart
// Light Theme
theme: ThemeData.light(useMaterial3: true).copyWith(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, 
    brightness: Brightness.light
  ),
)

// Dark Theme
darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
  colorScheme: const ColorScheme.dark(
    primary: Colors.blue,
    secondary: Colors.amber,
  ),
)
```

---

## 4. TIPOGRAFI DAN FONT

### 4.1 Font Family
Aplikasi menggunakan **default Flutter font** (Roboto) dengan konfigurasi:

| Font | Usage |
|------|-------|
| **Roboto** | Primary font untuk semua teks |
| **Material Icons** | Iconography |
| **Cupertino Icons** | iOS-style icons |

**File:** `pubspec.yaml`
```yaml
dependencies:
  google_fonts: ^8.0.2  # Available for future custom fonts
  
flutter:
  uses-material-design: true
```

### 4.2 Typography Hierarchy

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| **Display Large** | 32-36px | w900 | Statistic numbers |
| **Headline Large** | 28px | w800 | Page titles |
| **Headline Medium** | 24px | w700 | Section headers |
| **Headline Small** | 20px | w600 | Card titles |
| **Title Large** | 18px | w600 | Subsection headers |
| **Title Medium** | 16px | w600 | Button text, labels |
| **Body Large** | 16px | w500 | Primary body text |
| **Body Medium** | 14px | w500 | Secondary text |
| **Body Small** | 12-13px | w400 | Captions, hints |
| **Label Large** | 16px | w700 | Button labels uppercase |

### 4.3 Typography Implementation

**Splash Page:**
```dart
const Text(
  'E-Ticketing Helpdesk',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
)
```

**Login Page:**
```dart
// Heading
TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w800,
  color: Colors.black87,
  letterSpacing: -0.5,
)

// Subheading
TextStyle(
  fontSize: 15,
  color: Colors.black54,
  fontWeight: FontWeight.w500,
)

// Button
TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.2,
)
```

**Dashboard Stat Cards:**
```dart
// Count Number
TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.w900,
  color: color,
  letterSpacing: -1,
)

// Label
TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: Colors.blueGrey,
)
```

### 4.4 Text Color Guidelines

| Context | Light Mode | Dark Mode |
|---------|------------|-----------|
| Primary Text | `Colors.black87` | `Colors.white` |
| Secondary Text | `Colors.black54` | `Colors.white70` |
| Disabled | `Colors.black38` | `Colors.white38` |
| Hint | `Colors.grey.shade600` | `Colors.grey.shade400` |

---

## 5. WIREFRAME DESAIN

### 5.1 Application Flow Structure

```
┌─────────────────────────────────────────────────────────────┐
│                      SPLASH SCREEN                          │
│                   (3 seconds delay)                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │    Check Auth State    │
        └──────────┬─────────────┘
                   │
         ┌─────────┴─────────┐
         │                   │
         ▼                   ▼
┌───────────────┐    ┌───────────────┐
│ Not Logged In │    │  Logged In    │
└───────┬───────┘    └───────┬───────┘
        │                    │
        ▼                    ▼
┌───────────────┐    ┌───────────────┐
│  LOGIN PAGE   │    │  Check Role   │
└───────┬───────┘    └───────┬───────┘
        │                    │
        ▼         ┌──────────┼──────────┐
┌───────────────┐ │          │          │
│ REGISTER PAGE │ ▼          ▼          ▼
└───────────────┘ ┌─────┐  ┌─────┐  ┌─────┐
                  │USER │  │HELP │  │ADMIN│
                  │HOME │  │DESK │  │HOME │
                  └─────┘  └─────┘  └─────┘
```

### 5.2 Screen Wireframes

#### 5.2.1 Splash Screen
```
┌─────────────────────┐
│                     │
│                     │
│    ┌───────────┐    │
│    │   Icon    │    │
│    │ (support_ │    │
│    │  agent)   │    │
│    └───────────┘    │
│                     │
│  E-Ticketing Helpdes│
│                     │
│                     │
└─────────────────────┘
```

#### 5.2.2 Login Page
```
┌─────────────────────┐
│ [Gradient Background]│
│                     │
│    ┌───────────┐    │
│    │   Icon    │    │
│    └───────────┘    │
│                     │
│  Selamat Datang!    │
│  Masuk untuk...     │
│                     │
│  ┌───────────────┐ │
│  │  Username     │ │
│  └───────────────┘ │
│  ┌───────────────┐ │
│  │  Password     │ │
│  └───────────────┘ │
│       [Lupa Password?]│
│  ┌───────────────┐ │
│  │    MASUK      │ │
│  └───────────────┘ │
│                     │
│  Belum punya akun?  │
│  [Daftar di sini]   │
└─────────────────────┘
```

#### 5.2.3 Home Page (Bottom Navigation)
```
┌─────────────────────┐
│     Dashboard       │ [🔔]
├─────────────────────┤
│ Statistik Tiket     │
│ ┌─────┐   ┌─────┐  │
│ │ 12  │   │  5  │  │
│ │Total│   │Wait │  │
│ └─────┘   └─────┘  │
│ ┌─────┐   ┌─────┐  │
│ │  3  │   │  4  │  │
│ │Prog │   │Done │  │
│ └─────┘   └─────┘  │
│                     │
│ Aktivitas Terbaru   │
│ ┌───────────────┐  │
│ │ [Icon] Tiket 1│  │
│ └───────────────┘  │
│ ┌───────────────┐  │
│ │ [Icon] Tiket 2│  │
│ └───────────────┘  │
├─────────────────────┤
│[🏠] [🎫] [👤]       │
│Dash  Tiket Profile  │
└─────────────────────┘
```

#### 5.2.4 Create Ticket Page
```
┌─────────────────────┐
│ ← Buat Tiket Baru   │
├───────────────────────┤
│                     │
│ Judul Masalah       │
│ ┌─────────────────┐ │
│ │                 │ │
│ └─────────────────┘ │
│                     │
│ Deskripsi Detail    │
│ ┌─────────────────┐ │
│ │                 │ │
│ │                 │ │
│ │                 │ │
│ └─────────────────┘ │
│                     │
│ Unggah Laporan      │
│ ┌─────────────────┐ │
│ │  [Cloud Icon]   │ │
│ │ Belum ada file  │ │
│ └─────────────────┘ │
│                     │
│ [📷 Kamera] [📁 File]│
│                     │
│  ┌───────────────┐  │
│  │  KIRIM TIKET  │  │
│  └───────────────┘  │
└─────────────────────┘
```

#### 5.2.5 Ticket Detail Page
```
┌─────────────────────┐
│ ← Detail Tiket      │
├─────────────────────┤
│                     │
│ #123 - Judul Tiket  │
│ [Badge: Pending]    │
│                     │
│ ┌───────────────┐   │
│ │ Status:       │   │
│ │ Pending       │   │
│ │ Dibuat:       │   │
│ │ 2024-01-15    │   │
│ └───────────────┘   │
│                     │
│ [Mulai] [Selesai]   │
│                     │
│ Riwayat             │
│ ●───○───○           │
│ Created → Prog → Done│
│                     │
│ Komentar            │
│ ┌───────────────┐   │
│ │ Add comment...│   │
│ └───────────────┘   │
└─────────────────────┘
```

### 5.3 Component Library

#### 5.3.1 Buttons
| Type | Style | Usage |
|------|-------|-------|
| **Primary** | Filled, Blue | Main actions (Submit, Login) |
| **Secondary** | Outlined | Alternative actions |
| **Tertiary** | Text only | Link, Cancel |
| **Icon** | Circular | Camera, Attachment |

#### 5.3.2 Cards
```
┌─────────────────────┐
│ ┌───┐ Title         │
│ │   │ Subtitle      │
│ └───┘ Trailing      │
└─────────────────────┘
```

#### 5.3.3 Input Fields
```
┌─────────────────────┐
│ ┌───┐ Label         │
│ │ 👤│ ┌───────────┐ │ 
│ └───┘ │   Text    │ │
│       └───────────┘ │
└─────────────────────┘
```

---

## 6. PROTOTIPE DESAIN

### 6.1 Screen Specifications

#### 6.1.1 Splash Screen
- **Background:** White
- **Duration:** 3 seconds
- **Logo:** `Icons.support_agent` (size: 80)
- **Logo Color:** Colors.blue
- **Text:** "E-Ticketing Helpdesk"
- **Text Style:** 24px, Bold

#### 6.1.2 Login Page
| Element | Specification |
|---------|--------------|
| **Background** | Linear Gradient (blue.shade50 → white → blue.shade100) |
| **Card** | White, borderRadius: 24, shadow |
| **Logo Container** | Circle, white, shadow |
| **Logo** | Icons.support_agent_rounded, size: 80, blueAccent |
| **Title** | 28px, w800, black87 |
| **Subtitle** | 15px, w500, black54 |
| **Input Fields** | borderRadius: 16, filled: grey.shade50 |
| **Button** | BlueAccent, height: 54, borderRadius: 16 |

#### 6.1.3 Dashboard Page
| Element | Specification |
|---------|--------------|
| **AppBar** | Default, title: "Dashboard", actions: [notification] |
| **Stat Cards** | 2x2 Grid, aspectRatio: 1.5 |
| **Card Design** | elevation: 2, borderRadius: 16, gradient border |
| **Count Number** | 32px, w900 |
| **Status Badge** | Orange/Purple/Green with icon |

### 6.2 Responsive Design

**Breakpoints:**
- **Mobile:** < 600px (default)
- **Tablet:** 600-1024px (adaptive grid)
- **Desktop:** > 1024px (maxWidth constraints)

### 6.3 Animation & Transitions

| Animation | Duration | Usage |
|-----------|----------|-------|
| Page Route | 300ms | Navigation between screens |
| Button Press | 150ms | Visual feedback |
| Loading | Infinite | CircularProgressIndicator |
| Snackbar | 4 seconds | Success/Error feedback |
| Splash | 3 seconds | Initial loading |

### 6.4 Interaction Patterns

**Login Flow:**
1. User enters username/password
2. Form validation (real-time)
3. Loading indicator on button
4. Success: Snackbar + Route to Home
5. Error: Snackbar with error message

**Create Ticket Flow:**
1. Fill title (min 5 chars)
2. Fill description (min 10 chars)
3. Optional: Attach files (camera/gallery)
4. Submit with loading state
5. Success: Return to list + Snackbar

---

## 7. ARSITEKTUR APLIKASI

### 7.1 Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │   Pages     │  │   BLoC      │  │  Providers  │          │
│  │  (UI/UX)    │  │   (State)   │  │ (Riverpod)  │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
├─────────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │  Entities   │  │  Use Cases  │  │ Repositories│          │
│  │ (Business)  │  │ (Business)   │  │ (Interface) │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
├─────────────────────────────────────────────────────────────┤
│                       DATA LAYER                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │   Models    │  │ DataSources │  │ Repositories│          │
│  │  (JSON)     │  │ (Supabase)  │  │   (Impl)    │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
├─────────────────────────────────────────────────────────────┤
│                    EXTERNAL LAYER                            │
│                    (Supabase Services)                         │
└─────────────────────────────────────────────────────────────┘
```

### 7.2 Data Flow
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

### 7.3 Project Structure
```
lib/
├── main.dart                      # Entry point
├── core/
│   ├── services/
│   │   ├── app_router.dart        # GoRouter configuration
│   │   └── supabase_service.dart  # Supabase client
│   └── theme/
│       └── theme_provider.dart    # Theme state management
├── features/
│   ├── auth/                      # Authentication feature
│   ├── dashboard/                 # Dashboard feature
│   ├── home/                      # Home with bottom nav
│   ├── notification/              # Notification feature
│   ├── profile/                   # Profile feature
│   └── ticket/                    # Ticket feature (complete)
│       ├── data/
│       ├── domain/
│       ├── presentation/
│       └── injection_container.dart
```

### 7.4 State Management

**Dual Approach:**
1. **Flutter BLoC** - For Ticket feature (complex state)
2. **Riverpod** - For app-wide (routing, theme, auth)

---

## 8. FITUR DAN FUNGSIONALITAS

### 8.1 Functional Requirements

| ID | Feature | Status |
|----|---------|--------|
| FR-001 | Sistem Autentikasi | ✅ Complete |
| FR-005 | Membuat Tiket | ✅ Complete |
| FR-005.2 | File Attachment | ✅ Complete |
| FR-006 | Daftar Tiket | ✅ Complete |
| FR-006.3 | Update Status | ✅ Complete |
| FR-006.4 | Assign Ticket | ✅ Complete |
| FR-007 | Tambah Komentar | ✅ Complete |
| FR-010 | Riwayat Tiket | ✅ Complete |
| FR-011 | Dashboard Statistics | ✅ Complete |

### 8.2 Role-Based Access Control

| Feature | User | Helpdesk | Admin |
|---------|------|----------|-------|
| Create Ticket | ✅ | ✅ | ✅ |
| View Own Tickets | ✅ | ✅ | ✅ |
| View All Tickets | ❌ | ✅ | ✅ |
| Update Status | ❌ | ✅ | ✅ |
| Assign Ticket | ❌ | ✅ | ✅ |
| Delete Ticket | ❌ | ❌ | ✅ |

### 8.3 Dependencies

```yaml
dependencies:
  flutter_riverpod: ^3.3.1    # State management
  go_router: ^17.2.0          # Routing
  supabase_flutter: ^2.12.2   # Backend
  flutter_bloc: ^9.1.1        # BLoC pattern
  file_picker: ^8.1.3         # File upload
  image_picker: ^1.2.1        # Camera
  get_it: ^9.2.1              # Dependency injection
  google_fonts: ^8.0.2        # Typography
```

---

## 9. KESIMPULAN

### 9.1 Summary
E-Ticketing Helpdesk adalah aplikasi mobile Flutter yang berhasil mengimplementasikan:
1. Clean Architecture dengan 3 layer (Presentation, Domain, Data)
2. Dual state management (BLoC + Riverpod)
3. Material 3 Design dengan color scheme blue-based
4. Role-based access control untuk 3 jenis pengguna
5. File attachment dengan kamera dan galeri
6. Real-time dashboard statistics

### 9.2 Technical Achievements
- ✅ 100% Feature completion (9 FR implemented)
- ✅ Clean Architecture implementation
- ✅ Dependency Injection with GetIt
- ✅ Supabase integration (Auth, Database, Storage)
- ✅ Responsive UI design

### 9.3 Future Improvements
- Push notification
- Dark mode optimization
- Offline support
- Search and filter enhancement
- Export ticket reports

---

## DAFTAR PUSTAKA

1. Flutter Documentation - https://docs.flutter.dev
2. Material Design 3 - https://m3.material.io
3. Supabase Documentation - https://supabase.com/docs
4. Flutter BLoC Pattern - https://bloclibrary.dev
5. Clean Architecture - Robert C. Martin

---

**Dibuat oleh:** Muhammad Raka Razzani (434241056)  
**Kelas:** B2  
**Tanggal:** April 2026

---
