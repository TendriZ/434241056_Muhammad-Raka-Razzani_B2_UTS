import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
}

// Notifier untuk notifikasi
class NotificationNotifier extends StateNotifier<NotificationState> {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;
  StreamSubscription? _authSubscription;

  NotificationNotifier(this._supabase) : super(NotificationState(notifications: [])) {
    _initialize();
  }

  void _initialize() {
    // Listen untuk perubahan auth state
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
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
    if (_supabase.auth.currentUser != null) {
      _subscribeToTicketUpdates();
      _loadNotificationHistory();
    }
  }

  void _subscribeToTicketUpdates() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Subscribe ke tiket yang berhubungan dengan user
    _channel = _supabase.channel('ticket_updates:$userId');

    _channel!.on(
      RealtimeListenEventType.postgres_changes,
      channel: 'tickets',
      event: '*',
      schema: 'public',
      table: 'tickets',
      filter: RealtimeFilter.in('user_id', [userId]),
      callback: (payload, [ref]) {
        _handleTicketChange(payload);
      },
    ).subscribe();

    // Juga subscribe ke ticket_history untuk update status/komentar
    final historyChannel = _supabase.channel('ticket_history_updates:$userId');
    historyChannel.on(
      RealtimeListenEventType.postgres_changes,
      channel: 'ticket_history',
      event: 'INSERT',
      schema: 'public',
      table: 'ticket_history',
      callback: (payload, [ref]) {
        _handleTicketHistoryInsert(payload);
      },
    ).subscribe();
  }

  void _handleTicketChange(dynamic payload) {
    final record = payload['record'] as Map<String, dynamic>;
    final eventType = payload['eventType'] as String;

    String title = '';
    String message = '';

    switch (eventType) {
      case 'INSERT':
        title = 'Tiket Baru Dibuat';
        message = 'Tiket "${record['title']}" berhasil dibuat.';
        break;
      case 'UPDATE':
        final oldStatus = payload['old_record']['status'];
        final newStatus = record['status'];
        if (oldStatus != newStatus) {
          title = 'Status Tiket Diperbarui';
          message = 'Tiket "${record['title']}" sekarang statusnya: $_formatStatus(newStatus)';
        } else if (record['assigned_to'] != null && record['assigned_to'] != payload['old_record']['assigned_to']) {
          title = 'Tiket Ditugaskan';
          message = 'Tiket "${record['title']}" telah ditugaskan.';
        } else {
          return; // Skip update lain
        }
        break;
      case 'DELETE':
        title = 'Tiket Dihapus';
        message = 'Tiket "${record['title']}" telah dihapus.';
        break;
      default:
        return;
    }

    _addNotification(
      title: title,
      message: message,
      ticketId: record['id'],
    );
  }

  void _handleTicketHistoryInsert(dynamic payload) {
    final record = payload['record'] as Map<String, dynamic>;
    final action = record['action'];
    final message = record['message'];

    // Cek apakah ini update status
    if (action == 'Status Update' || action == 'Assigned') {
      final userId = _supabase.auth.currentUser?.id;
      // Hanya notifikasi jika bukan action sendiri
      if (record['user_id'] != userId) {
        _addNotification(
          title: 'Update Tiket',
          message: message,
          ticketId: record['ticket_id'],
        );
      }
    }
  }

  void _addNotification({required String title, required String message, String? ticketId}) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      ticketId: ticketId,
      createdAt: DateTime.now(),
    );

    state = NotificationState(
      notifications: [notification, ...state.notifications],
    );
  }

  Future<void> _loadNotificationHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Load history tiket terakhir untuk menampilkan notifikasi awal
      final response = await _supabase
          .from('tickets')
          .select('id, title, status, updated_at')
          .eq('user_id', userId)
          .order('updated_at', ascending: false)
          .limit(10);

      if (response != null) {
        // Bisa ditambahkan logika untuk load history notifikasi
        // Untuk sekarang kita mulai dengan list kosong
      }
    } catch (e) {
      if (kDebugMode) print('Error loading notification history: $e');
    }
  }

  void markAsRead(String notificationId) {
    final updated = state.notifications.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    state = NotificationState(notifications: updated);
  }

  void markAllAsRead() {
    final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = NotificationState(notifications: updated);
  }

  void clearAll() {
    state = NotificationState(notifications: []);
  }

  void _unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'on_progress':
        return 'Diproses';
      case 'resolved':
        return 'Selesai';
      default:
        return status;
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    _authSubscription?.cancel();
    super.dispose();
  }
}

// Provider
final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return NotificationNotifier(supabase);
});
