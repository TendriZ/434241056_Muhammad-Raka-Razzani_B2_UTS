import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/supabase_service.dart';

// Model untuk notifikasi
class AppNotification {
  final String id;
  final String title;
  final String message;
  final String? ticketId;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.ticketId,
    required this.createdAt,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      ticketId: ticketId,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

// Notifikasi State
class NotificationState {
  final List<AppNotification> notifications;
  final int unreadCount;

  NotificationState({required this.notifications})
      : unreadCount = notifications.where((n) => !n.isRead).length;

  NotificationState copyWith({List<AppNotification>? notifications}) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
    );
  }
}

// Notifier for notification state (Riverpod 3.x API)
class NotificationNotifier extends Notifier<NotificationState> {
  SupabaseClient? _supabase;
  RealtimeChannel? _channel;
  RealtimeChannel? _historyChannel;
  StreamSubscription? _authSubscription;
  Set<String> _readNotificationIds = {};
  SharedPreferences? _prefs;

  @override
  NotificationState build() {
    _initialize();
    return NotificationState(notifications: []);
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _readNotificationIds = (_prefs?.getStringList('read_notifications') ?? []).toSet();

    final supabase = ref.read(supabaseClientProvider);
    _supabase = supabase;

    // Listen untuk perubahan auth state
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        // User logged in, subscribe to realtime updates
        _subscribeToTicketUpdates();
        _loadNotificationHistory();
      } else {
        // User logged out, unsubscribe
        _unsubscribe();
        state = NotificationState(notifications: []);
      }
    });

    // Jika sudah login saat inisialisasi
    if (supabase.auth.currentUser != null) {
      _subscribeToTicketUpdates();
      _loadNotificationHistory();
    }
  }

  void _subscribeToTicketUpdates() {
    final supabase = _supabase;
    if (supabase == null) return;

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Subscribe to ticket updates using correct Supabase API
      _channel = supabase
          .channel('public:tickets:$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'tickets',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              _handleTicketChange(payload);
            },
          )
          .subscribe();

      // Subscribe to ticket history
      _historyChannel = supabase
          .channel('public:ticket_history:$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'ticket_history',
            callback: (payload) {
              _handleTicketHistoryInsert(payload);
            },
          )
          .subscribe();
    } catch (e) {
      if (kDebugMode) print('Error subscribing to realtime: $e');
    }
  }

  void _handleTicketChange(PostgresChangePayload payload) {
    try {
      final eventType = payload.eventType;
      final record = payload.newRecord as Map<String, dynamic>?;

      if (record == null) return;

      String title = '';
      String message = '';

      switch (eventType) {
        case PostgresChangeEvent.insert:
          title = 'Tiket Baru Dibuat';
          message = 'Tiket "${record['title']}" berhasil dibuat.';
          break;
        case PostgresChangeEvent.update:
          final oldRecord = payload.oldRecord as Map<String, dynamic>?;
          final oldStatus = oldRecord?['status'];
          final newStatus = record['status'];
          if (oldStatus != newStatus) {
            title = 'Status Tiket Diperbarui';
            message = 'Tiket "${record['title']}" sekarang statusnya: $_formatStatus(newStatus ?? '')';
          } else if (record['assigned_to'] != null) {
            title = 'Tiket Ditugaskan';
            message = 'Tiket "${record['title']}" telah ditugaskan.';
          } else {
            return;
          }
          break;
        case PostgresChangeEvent.delete:
          title = 'Tiket Dihapus';
          message = 'Tiket "${record['title']}" telah dihapus.';
          break;
        default:
          return;
      }

      _addNotification(
        title: title,
        message: message,
        ticketId: record['id']?.toString(),
      );
    } catch (e) {
      if (kDebugMode) print('Error handling ticket change: $e');
    }
  }

  void _handleTicketHistoryInsert(PostgresChangePayload payload) {
    try {
      final record = payload.newRecord as Map<String, dynamic>?;
      if (record == null) return;

      final action = record['action'];
      final message = record['message'];

      // Cek apakah ini update status
      if (action == 'Status Update' || action == 'Assigned') {
        final supabase = _supabase;
        if (supabase == null) return;

        final userId = supabase.auth.currentUser?.id;
        // Hanya notifikasi jika bukan action sendiri
        if (record['user_id'] != userId) {
          _addNotification(
            title: 'Update Tiket',
            message: message?.toString() ?? '',
            ticketId: record['ticket_id']?.toString(),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error handling ticket history: $e');
    }
  }

  void _addNotification({required String title, required String message, String? ticketId}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final notification = AppNotification(
      id: id,
      title: title,
      message: message,
      ticketId: ticketId,
      createdAt: DateTime.now(),
      isRead: _readNotificationIds.contains(id),
    );

    state = NotificationState(
      notifications: [notification, ...state.notifications],
    );
  }

  Future<void> _loadNotificationHistory() async {
    try {
      final supabase = _supabase;
      if (supabase == null) return;

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final profile = await supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      final isUser = profile?['role'] == 'user' || profile?['role'] == null;
      final historyList = <AppNotification>[];

      // Ambil tiket terakhir
      List<dynamic> tickets;
      if (isUser) {
        tickets = await supabase
            .from('tickets')
            .select('id, title, status, created_at, updated_at')
            .eq('user_id', userId)
            .order('created_at', ascending: false)
            .limit(20);
      } else {
        tickets = await supabase
            .from('tickets')
            .select('id, title, status, created_at, updated_at')
            .order('created_at', ascending: false)
            .limit(20);
      }

      for (final t in tickets) {
        final ticketId = t['id'].toString();
        final title = t['title'] ?? '';

        historyList.add(AppNotification(
          id: 'ticket-$ticketId-created',
          title: 'Tiket Baru Dibuat',
          message: 'Tiket "$title" berhasil dibuat.',
          ticketId: ticketId,
          createdAt: DateTime.tryParse(t['created_at'] ?? '') ?? DateTime.now(),
          isRead: _readNotificationIds.contains('ticket-$ticketId-created'),
        ));

        if (t['status'] == 'on_progress') {
          historyList.add(AppNotification(
            id: 'ticket-$ticketId-progress',
            title: 'Status Tiket Diperbarui',
            message: 'Tiket "$title" sekarang statusnya: Diproses',
            ticketId: ticketId,
            createdAt: DateTime.tryParse(t['updated_at'] ?? '') ?? DateTime.now(),
            isRead: _readNotificationIds.contains('ticket-$ticketId-progress'),
          ));
        } else if (t['status'] == 'resolved') {
          historyList.add(AppNotification(
            id: 'ticket-$ticketId-resolved',
            title: 'Tiket Selesai',
            message: 'Tiket "$title" telah selesai diproses.',
            ticketId: ticketId,
            createdAt: DateTime.tryParse(t['updated_at'] ?? '') ?? DateTime.now(),
            isRead: _readNotificationIds.contains('ticket-$ticketId-resolved'),
          ));
        }
      }

      // Ambil history komentar/action (untuk ticket_history)
      List<dynamic> historyRows;
      if (isUser) {
        final userTicketIds = tickets.map((t) => t['id']).toList();
        if (userTicketIds.isEmpty) {
          state = NotificationState(notifications: historyList);
          return;
        }
        historyRows = await supabase
            .from('ticket_history')
            .select('id, ticket_id, action, message, created_at, tickets!inner(title)')
            .inFilter('ticket_id', userTicketIds)
            .order('created_at', ascending: false)
            .limit(20);
      } else {
        historyRows = await supabase
            .from('ticket_history')
            .select('id, ticket_id, action, message, created_at, tickets!inner(title)')
            .order('created_at', ascending: false)
            .limit(20);
      }

      for (final h in historyRows) {
        final action = h['action'] ?? '';
        final ticketId = h['ticket_id']?.toString() ?? '';

        historyList.add(AppNotification(
          id: 'history-${h['id']}',
          title: action == 'Comment' ? 'Komentar Baru' : 'Update Tiket',
          message: h['message']?.toString() ?? '',
          ticketId: ticketId,
          createdAt: DateTime.tryParse(h['created_at'] ?? '') ?? DateTime.now(),
          isRead: _readNotificationIds.contains('history-${h['id']}'),
        ));
      }

      // Urutkan berdasarkan created_at descending
      historyList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = NotificationState(notifications: historyList);
    } catch (e) {
      if (kDebugMode) print('Error loading notification history: $e');
      state = NotificationState(notifications: []);
    }
  }

  void markAsRead(String notificationId) {
    _readNotificationIds.add(notificationId);
    _prefs?.setStringList('read_notifications', _readNotificationIds.toList());

    final updated = state.notifications.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    state = NotificationState(notifications: updated);
  }

  void markAllAsRead() {
    for (var n in state.notifications) {
      _readNotificationIds.add(n.id);
    }
    _prefs?.setStringList('read_notifications', _readNotificationIds.toList());

    final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = NotificationState(notifications: updated);
  }

  void clearAll() {
    _readNotificationIds.clear();
    _prefs?.remove('read_notifications');
    state = NotificationState(notifications: []);
  }

  void _unsubscribe() {
    _channel?.unsubscribe();
    _historyChannel?.unsubscribe();
    _channel = null;
    _historyChannel = null;
  }

  String _formatStatus(String? status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'on_progress':
        return 'Diproses';
      case 'resolved':
        return 'Selesai';
      default:
        return status ?? '';
    }
  }
}

// Providers (Riverpod 3.x API)
final notificationProvider = NotifierProvider<NotificationNotifier, NotificationState>(
  NotificationNotifier.new,
);
