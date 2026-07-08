# E-Ticketing Helpdesk — Mobile Application

Aplikasi mobile Flutter untuk mengelola tiket support/helpdesk dengan role-based access control (User, Helpdesk, Admin) dan realtime updates via Supabase.

## Fitur Utama

| Kode | Fitur | Status |
|------|-------|--------|
| FR-001 | Autentikasi (Login, Register, Forgot Password) | ✅ |
| FR-004 | Reset Password | ✅ |
| FR-005 | Membuat Tiket + File Attachment | ✅ |
| FR-006 | Daftar Tiket (role-based filter) | ✅ |
| FR-006.3 | Update Status Tiket | ✅ |
| FR-006.4 | Assign Tiket ke Helpdesk | ✅ |
| FR-007 | Tambah Komentar | ✅ |
| FR-008 | Notifikasi Realtime (Supabase Realtime) | ✅ |
| FR-009 | Statistik Tiket | ✅ |
| FR-010 | Riwayat Tiket | ✅ |
| FR-011 | Tracking Tiket | ✅ |

## Tech Stack

| Komponen | Teknologi |
|----------|-----------|
| **Framework** | Flutter 3.0+ |
| **Language** | Dart 3.0+ |
| **State Management** | Riverpod 3.x |
| **Routing** | GoRouter |
| **Backend** | Supabase (Auth, PostgreSQL, Storage, Realtime) |
| **Architecture** | Layered Architecture + Riverpod |

## Project Structure

```
lib/
├── core/
│   ├── theme/              # Design System (Material 3, Light/Dark)
│   └── services/           # Supabase client, GoRouter
├── features/
│   ├── auth/               # Login, Register, Forgot Password
│   ├── home/               # Role-based Home pages
│   ├── ticket/             # CRUD Tiket (Create, List, Detail, History)
│   ├── dashboard/          # Statistik tiket
│   ├── notification/       # Notifikasi realtime
│   ├── profile/            # Manajemen profil
│   └── admin/              # Manajemen user (Admin only)
└── main.dart
```

## Quick Start

```bash
# Clone & install
flutter pub get

# Jalankan
flutter run

# Build APK release
flutter build apk --release
```

## Database Schema

3 tabel utama di Supabase PostgreSQL:

| Tabel | Keterangan |
|-------|------------|
| `profiles` | Data user (id, name, username, role) |
| `tickets` | Tiket helpdesk (title, description, status, priority, category) |
| `ticket_history` | Riwayat perubahan dan komentar tiket |

Lihat detail di [`schema.md`](schema.md) dan [`LAPORAN_UAS.md`](LAPORAN_UAS.md).

## Role & Permissions

| Feature | User | Helpdesk | Admin |
|---------|------|----------|-------|
| Create Ticket | ✅ Own | ✅ Any | ✅ Any |
| View Tickets | ✅ Own | ✅ All | ✅ All |
| Assign | ❌ | ❌ | ✅ To Staff |
| Finish | ❌ | ✅ Own Task | ✅ Any |
| Comment | ✅ Own | ✅ All | ✅ All |
| History | ✅ Own | ✅ All | ✅ All |
| Statistics | ✅ Own | ✅ Assigned | ✅ All |
| Manage Users | ❌ | ❌ | ✅ |
| Delete Ticket | ❌ | ❌ | ✅ |

## Dokumentasi Lainnya

- [LAPORAN_UAS.md](LAPORAN_UAS.md) — Laporan lengkap (UI/UX, Database, API)
- [schema.md](schema.md) — Database schema
- [scripts/api_curl_test.md](scripts/api_curl_test.md) — cURL API test scripts

## License

Project ini dibuat untuk UAS Mata Kuliah Aplikasi Mobile Praktikum — Universitas Airlangga.
