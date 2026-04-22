import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

// Provider untuk mengambil daftar Tiket dari database
final ticketsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  // Cek profile user untuk mendapatkan role
  final profile = await ref.watch(userProfileProvider.future);
  
  if (profile == null) return [];

  final role = profile['role'];

  // Jika usernya end-user murni, filter hanya tiket miliknya (FR-002)
  if (role == 'user' || role == null) {
    final response = await supabase
        .from('tickets')
        .select()
        .eq('user_id', supabase.auth.currentUser!.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  } else {
    // Jika admin atau helpdesk, ambil semua tiket (FR-008 & FR-009)
    final response = await supabase
        .from('tickets')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
});

// Provider untuk baca detail tiket secara spesifik
final ticketDetailProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, ticketId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final ticket = await supabase.from('tickets').select().eq('id', ticketId).maybeSingle();

  if (ticket == null) return null;

  final ticketData = Map<String, dynamic>.from(ticket);

  final assignedTo = ticketData['assigned_to'];
  if (assignedTo != null) {
    final assignee = await supabase
        .from('profiles')
        .select('name')
        .eq('id', assignedTo)
        .maybeSingle();
    ticketData['assigned_to_name'] = assignee?['name'];
  } else {
    ticketData['assigned_to_name'] = null;
  }

  return ticketData;
});

// Provider untuk menghitung Statistik secara otomatis dari tabel
final ticketStatsProvider = FutureProvider<Map<String, int>>((ref) async {

  final tickets = await ref.watch(ticketsProvider.future);
  
  int pending = 0;
  int onProgress = 0;
  int resolved = 0;

  for (var t in tickets) {
    if (t['status'] == 'pending') {
      pending++;
    } else if (t['status'] == 'on_progress') {
      onProgress++;
    } else if (t['status'] == 'resolved') {
      resolved++;
    }
  }

  return {
    'total': tickets.length,
    'pending': pending,
    'on_progress': onProgress,
    'resolved': resolved,
  };
});

// Provider untuk history beserta balasan/komentar dari tiket
final ticketHistoryProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, ticketId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final response = await supabase
      .from('ticket_history')
      .select()
      .eq('ticket_id', ticketId)
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(response);
});

