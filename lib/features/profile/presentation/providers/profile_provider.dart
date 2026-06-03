import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';

// Mengambil Data Profil spesifik user yang sedang Sign In
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;

  if (user == null) return null;

  final response = await supabase
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle(); // Karena satu user 1 profile

  // Fetch total tiket yang dibuat oleh user
  final ticketCountResponse = await supabase
      .from('tickets')
      .select('id')
      .eq('user_id', user.id);

  final ticketCount = ticketCountResponse != null ? (ticketCountResponse as List).length : 0;

  // Gabungkan data profile dengan ticket count
  if (response != null) {
    response['ticket_count'] = ticketCount;
  }

  return response;
});
