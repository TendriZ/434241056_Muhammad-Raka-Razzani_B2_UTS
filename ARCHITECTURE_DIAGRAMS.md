# Architecture & Data Flow Diagrams

## 🏗️ Clean Architecture Layers

```
┌────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                          │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │              SCREENS & UI COMPONENTS                     │ │
│  │  • CreateTicketScreen (FR-005, FR-005.2)                │ │
│  │  • TicketListScreen (FR-006)                            │ │
│  │  • TicketDetailScreen (FR-006.3, 6.4, 7, 10)            │ │
│  │  • DashboardScreen (FR-008, 11)                         │ │
│  └──────────────────────────────────────────────────────────┘ │
│                           ▲                                    │
│                           │ State Updates                       │
│                           │                                    │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │         BLOC (State Management)                          │ │
│  │  Events:                                                 │ │
│  │  • CreateTicketEvent                                    │ │
│  │  • FetchTicketsEvent                                    │ │
│  │  • UpdateTicketStatusEvent                              │ │
│  │  • AssignTicketEvent                                    │ │
│  │  • AddTicketCommentEvent                                │ │
│  │  • FetchTicketHistoryEvent                              │ │
│  │  • FetchTicketStatisticsEvent                           │ │
│  │  • UploadTicketAttachmentEvent                          │ │
│  │  • DeleteTicketEvent                                    │ │
│  │                                                          │ │
│  │  States:                                                │ │
│  │  • TicketInitial, TicketLoading, TicketSuccess         │ │
│  │  • TicketsLoaded, TicketDetailLoaded                   │ │
│  │  • TicketHistoryLoaded, TicketStatisticsLoaded         │ │
│  │  • TicketError                                          │ │
│  └──────────────────────────────────────────────────────────┘ │
│                           │                                    │
│                           │ Events                             │
│                           ▼                                    │
├────────────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                              │
│                   (Business Logic)                             │
│                                                                │
│  ┌──────────────────────┐  ┌──────────────────────────────┐  │
│  │    USE CASES        │→ │  REPOSITORY INTERFACE        │  │
│  │                     │  │                              │  │
│  │ • CreateTicket      │  │ • createTicket()             │  │
│  │ • GetTickets        │  │ • getTickets()               │  │
│  │ • GetTicketDetail   │  │ • getTicketById()            │  │
│  │ • UpdateStatus      │  │ • updateTicketStatus()       │  │
│  │ • AssignTicket      │  │ • assignTicket()             │  │
│  │ • AddComment        │  │ • addTicketComment()         │  │
│  │ • GetHistory        │  │ • getTicketHistory()         │  │
│  │ • GetStatistics     │  │ • getTicketStatistics()      │  │
│  │ • UploadAttachment  │  │ • uploadTicketAttachment()   │  │
│  │ • DeleteTicket      │  │ • deleteTicket()             │  │
│  └──────────────────────┘  └──────────────────────────────┘  │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │              ENTITIES (Models)                           │ │
│  │  • TicketEntity                                          │ │
│  │  • TicketHistoryEntity                                   │ │
│  └──────────────────────────────────────────────────────────┘ │
│                           │                                    │
│                           │ Uses                               │
│                           ▼                                    │
├────────────────────────────────────────────────────────────────┤
│                       DATA LAYER                               │
│                   (Data Access)                                │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │         REPOSITORY IMPLEMENTATION                        │ │
│  │  Delegates to DataSource                                 │ │
│  │  Validates input                                         │ │
│  │  Error handling                                          │ │
│  └──────────────────────────────────────────────────────────┘ │
│                           │                                    │
│                           │ Calls                              │
│                           ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │      REMOTE DATA SOURCE (Supabase API)                   │ │
│  │                                                          │ │
│  │  • POST /tickets (create)                               │ │
│  │  • GET /tickets (list)                                  │ │
│  │  • GET /tickets/{id} (detail)                           │ │
│  │  • PATCH /tickets/{id} (update status)                  │ │
│  │  • POST /ticket_history (log action)                    │ │
│  │  • POST /ticket-attachments (upload file)               │ │
│  │  • DELETE /tickets/{id} (delete)                        │ │
│  └──────────────────────────────────────────────────────────┘ │
│                           │                                    │
│                           │ API Calls                          │
│                           ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │             MODELS (JSON Serialization)                  │ │
│  │  • TicketModel.fromJson()                               │ │
│  │  • TicketModel.toJson()                                 │ │
│  │  • TicketHistoryModel.fromJson()                        │ │
│  └──────────────────────────────────────────────────────────┘ │
│                           │                                    │
│                           ▼                                    │
├────────────────────────────────────────────────────────────────┤
│                   EXTERNAL (Backend)                           │
│                                                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │  Supabase    │  │   Cloud      │  │  Auth        │        │
│  │  Database    │  │   Storage    │  │  Service     │        │
│  │              │  │              │  │              │        │
│  │ • tickets    │  │ bucket:      │  │ • JWT tokens │        │
│  │ • ticket_    │  │ ticket-      │  │ • User info  │        │
│  │   history    │  │ attachments  │  │ • Roles      │        │
│  │              │  │              │  │              │        │
│  │ • RLS        │  │ • Public URL │  │ • RLS check  │        │
│  │   Policies   │  │   generation │  │              │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
└────────────────────────────────────────────────────────────────┘
```

---

## 📊 Data Flow - Create Ticket with File (FR-005 + FR-005.2)

```
USER ACTION:
  User fills title & description
  User selects image from gallery
  User clicks "Buat Tiket" button
         │
         ▼
┌─────────────────────────────────┐
│   CreateTicketScreen            │
│   ┌───────────────────────────┐ │
│   │ Validate inputs:          │ │
│   │ • Title (min 5 chars) ✓   │ │
│   │ • Description (min 10) ✓  │ │
│   │ • File size (max 10MB) ✓  │ │
│   └───────────────────────────┘ │
└─────────────────────────────────┘
         │
         ▼ context.read<TicketBloc>().add(
           CreateTicketEvent(...) + UploadAttachmentEvent(...))
         │
┌─────────────────────────────────┐
│   TicketBloc                    │
│   ┌───────────────────────────┐ │
│   │ _onCreateTicket()         │ │
│   │ _onUploadAttachment()     │ │
│   └───────────────────────────┘ │
└─────────────────────────────────┘
         │
         ▼ createTicketUseCase.call(...) +
           uploadAttachmentUseCase.call(...)
         │
┌─────────────────────────────────┐
│   Use Cases                     │
│   ┌───────────────────────────┐ │
│   │ repository.createTicket() │ │
│   │ repository.uploadFile()   │ │
│   └───────────────────────────┘ │
└─────────────────────────────────┘
         │
         ▼ Delegates to DataSource
         │
┌─────────────────────────────────┐
│   TicketRemoteDataSource        │
│   ┌───────────────────────────┐ │
│   │ POST /tickets:            │ │
│   │ {                         │ │
│   │   user_id: UUID,          │ │
│   │   title: String,          │ │
│   │   description: String,    │ │
│   │   status: 'pending'       │ │
│   │ }                         │ │
│   │                           │ │
│   │ POST /ticket-attachments: │ │
│   │ {                         │ │
│   │   file_bytes: Uint8List,  │ │
│   │   fileName: String        │ │
│   │ }                         │ │
│   └───────────────────────────┘ │
└─────────────────────────────────┘
         │
         ▼ HTTP Requests to Supabase
         │
┌─────────────────────────────────┐
│   Supabase Backend              │
│   ┌───────────────────────────┐ │
│   │ Database Insert:          │ │
│   │ tickets table             │ │
│   │                           │ │
│   │ Storage Upload:           │ │
│   │ tickets/{id}/{file}       │ │
│   └───────────────────────────┘ │
└─────────────────────────────────┘
         │
         ▼ Response: TicketModel + URL
         │
┌─────────────────────────────────┐
│   TicketModel (JSON Parse)      │
│   ├─ id: UUID                  │
│   ├─ user_id: UUID             │
│   ├─ title: String             │
│   ├─ description: String       │
│   ├─ status: 'pending'         │
│   ├─ created_at: DateTime      │
│   └─ file_url: String (URL)    │
└─────────────────────────────────┘
         │
         ▼ BLoC emits TicketSuccess()
         │
┌─────────────────────────────────┐
│   CreateTicketScreen            │
│   ┌───────────────────────────┐ │
│   │ BlocListener catches:     │ │
│   │ if (state is            │ │
│   │   TicketSuccess)        │ │
│   │   showSuccessDialog()   │ │
│   └───────────────────────────┘ │
└─────────────────────────────────┘
         │
         ▼
    "Sukses! Tiket dibuat"
    (Dialog shown)
         │
         ▼
    Redirect to List Screen
         │
         ▼
    Ticket visible in list! ✓
```

---

## 🔄 Data Flow - Update Status (FR-006.3)

```
USER ACTION:
  User clicks "Mulai" button on ticket detail
         │
         ▼
┌─────────────────────────────────┐
│   TicketDetailScreen            │
│   ┌───────────────────────────┐ │
│   │ _buildStatusSection()     │ │
│   │ Shows status buttons      │ │
│   │ Validate role:            │ │
│   │ Only helpdesk/admin ✓     │ │
│   └───────────────────────────┘ │
└─────────────────────────────────┘
         │
         ▼ context.read<TicketBloc>().add(
           UpdateTicketStatusEvent(
             ticketId: '...',
             newStatus: 'on_progress'))
         │
┌─────────────────────────────────┐
│   TicketBloc                    │
│   _onUpdateTicketStatus()       │
└─────────────────────────────────┘
         │
         ▼ updateStatusUseCase.call(...)
         │
┌─────────────────────────────────┐
│   repository.updateStatus()     │
│   └─ Validate status value      │
└─────────────────────────────────┘
         │
         ▼ dataSource.updateStatus(...)
         │
┌─────────────────────────────────────────────┐
│   Supabase                                  │
│   ┌───────────────────────────────────────┐ │
│   │ 1. PATCH /tickets                     │ │
│   │    WHERE id = ticketId                │ │
│   │    SET {                              │ │
│   │      status: 'on_progress',           │ │
│   │      updated_at: NOW()                │ │
│   │    }                                  │ │
│   │                                       │ │
│   │ 2. INSERT /ticket_history             │ │
│   │    {                                  │ │
│   │      ticket_id: ticketId,             │ │
│   │      user_id: currentUser,            │ │
│   │      action: 'Status Update',         │ │
│   │      message: 'Status diubah...',     │ │
│   │      status: 'on_progress'            │ │
│   │    }                                  │ │
│   └───────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
         │
         ▼ Response: true (success)
         │
┌─────────────────────────────────┐
│   TicketBloc                    │
│   emit(TicketSuccess())         │
│   Refresh detail & history      │
└─────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│   TicketDetailScreen            │
│   ┌───────────────────────────┐ │
│   │ Status badge changes:     │ │
│   │ 'pending' → 'on_progress' │ │
│   │ Color: orange → blue      │ │
│   │                           │ │
│   │ History shows:            │ │
│   │ "Admin User"              │ │
│   │ "Status Update"           │ │
│   │ "10 minutes ago"          │ │
│   └───────────────────────────┘ │
└─────────────────────────────────┘
         │
         ▼
    Ticket list updates! ✓
```

---

## 📱 UI Navigation Flow

```
┌─────────────────────┐
│  Splash / Auth      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────────────────────────────┐
│         DASHBOARD SCREEN (FR-008, 11)       │
│  ┌─────────────────────────────────────┐   │
│  │ Statistics Cards:                   │   │
│  │ Total | Pending | In Progress | Done│   │
│  │                                     │   │
│  │ Buttons:                            │   │
│  │ [Create Ticket] [View Tickets]      │   │
│  └─────────────────────────────────────┘   │
└───────────┬─────────────────────────────────┘
            │
    ┌───────┴───────┐
    │               │
    ▼               ▼
TICKET LIST     CREATE TICKET
SCREEN          SCREEN
(FR-006)        (FR-005)
    │               │
    │         ┌─────┴──────┐
    │         │            │
    │         ▼            ▼
    │      Title      File Upload
    │      Desc       (FR-005.2)
    │               [Camera]
    │               [Gallery]
    │
    ├─ Filter by: ┐
    │ ✓ All       │
    │ ✓ Pending   │
    │ ✓ In Prog   │
    │ ✓ Done      ┘
    │
    ▼
TICKET DETAIL SCREEN
(FR-006, 006.3, 006.4, 007, 010)
    │
    ├─ Header
    │  └─ Status: pending / on_progress / resolved
    │
    ├─ Ticket Info
    │  ├─ Title
    │  ├─ Description
    │  ├─ Created date
    │  └─ Assigned to
    │
    ├─ Status Update (FR-006.3)
    │  └─ [Pending] [Start] [Resolve] (if helpdesk/admin)
    │
    ├─ Assign Ticket (FR-006.4)
    │  └─ [Assign to...] (if helpdesk/admin)
    │
    ├─ History Timeline (FR-010)
    │  ├─ Status updates
    │  ├─ Assignments
    │  └─ Comments
    │
    └─ Comment Form (FR-007)
       └─ [Text input] [Submit]
```

---

## 🗄️ Database Schema & Relationships

```
┌─────────────────────────┐
│       users             │
├─────────────────────────┤
│ id (UUID) [PK]          │
│ email (VARCHAR)         │
│ role (VARCHAR)          │
│ created_at (TIMESTAMP)  │
└─────────────────────────┘
        ▲    │
        │    │ (1 to many)
        │    │
        │    ▼
┌─────────────────────────────────────┐
│           tickets                   │
├─────────────────────────────────────┤
│ id (UUID) [PK]                      │
│ user_id (UUID) [FK → users]        │
│ title (VARCHAR)                     │
│ description (TEXT)                  │
│ status (VARCHAR)                    │
│ assigned_to (UUID) [FK → users]    │
│ created_at (TIMESTAMP)              │
│ updated_at (TIMESTAMP)              │
└─────────────────────────────────────┘
        ▲    │
        │    │ (1 to many)
        │    │
        │    ▼
┌─────────────────────────────────────┐
│      ticket_history                 │
├─────────────────────────────────────┤
│ id (UUID) [PK]                      │
│ ticket_id (UUID) [FK → tickets]    │
│ user_id (UUID) [FK → users]        │
│ action (VARCHAR)                    │
│ message (TEXT)                      │
│ status (VARCHAR)                    │
│ created_at (TIMESTAMP)              │
└─────────────────────────────────────┘

Storage:
┌─────────────────────────────────────┐
│   ticket-attachments (bucket)       │
├─────────────────────────────────────┤
│ tickets/{ticketId}/                 │
│   {timestamp}-{fileName}            │
│                                     │
│ Example:                            │
│ tickets/uuid-1/1234567890-photo.jpg │
└─────────────────────────────────────┘
```

---

## 🔐 Role-Based Access Control

```
┌──────────────────────────────────────────────────────────┐
│                    USER ROLES                            │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  USER ROLE          HELPDESK ROLE       ADMIN ROLE      │
│  ├─ Create         ├─ Create            ├─ Create      │
│  │ ├─ Own only     │ ├─ Any              │ ├─ Any       │
│  │ └─ FR-005.2 ✓   │ └─ FR-005.2 ✓       │ └─ FR-005.2  │
│  │                 │                     │              │
│  ├─ Read           ├─ Read               ├─ Read        │
│  │ ├─ Own only     │ ├─ All              │ ├─ All       │
│  │ └─ FR-006 ✓     │ └─ FR-006 ✓         │ └─ FR-006    │
│  │                 │                     │              │
│  ├─ No Update      ├─ Update             ├─ Update      │
│  │ └─ FR-006.3 ✗   │ ├─ Status ✓         │ ├─ Status    │
│  │                 │ └─ FR-006.3 ✓       │ └─ FR-006.3  │
│  │                 │                     │              │
│  ├─ No Assign      ├─ Assign             ├─ Assign      │
│  │ └─ FR-006.4 ✗   │ ├─ To staff ✓       │ ├─ To staff  │
│  │                 │ └─ FR-006.4 ✓       │ └─ FR-006.4  │
│  │                 │                     │              │
│  ├─ Comment        ├─ Comment            ├─ Comment     │
│  │ └─ Own ✓        │ ├─ All ✓            │ ├─ All ✓     │
│  │ └─ FR-007 ✓     │ └─ FR-007 ✓         │ └─ FR-007 ✓  │
│  │                 │                     │              │
│  ├─ View History   ├─ View History       ├─ View History│
│  │ └─ Own ✓        │ ├─ All ✓            │ ├─ All ✓     │
│  │ └─ FR-010 ✓     │ └─ FR-010 ✓         │ └─ FR-010 ✓  │
│  │                 │                     │              │
│  ├─ Statistics     ├─ Statistics         ├─ Statistics  │
│  │ └─ Own ✓        │ ├─ All ✓            │ ├─ All ✓     │
│  │ └─ FR-008 ✓     │ └─ FR-008 ✓         │ └─ FR-008 ✓  │
│  │                 │                     │              │
│  └─ No Delete      └─ No Delete          └─ Delete ✓    │
│     FR-011 ✓          FR-011 ✓              FR-011 ✓    │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## ✨ Summary

This architecture provides:
- ✅ Clear separation of concerns (3 layers)
- ✅ Testable code (no dependencies between layers)
- ✅ Maintainable structure (easy to add features)
- ✅ Scalable design (supports many users)
- ✅ Secure implementation (RLS + validation)
- ✅ Professional state management (BLoC)

