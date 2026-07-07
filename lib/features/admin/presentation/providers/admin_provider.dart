import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

final usersProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String?>(
  (ref, filterRole) async {
    final supabase = ref.watch(supabaseClientProvider);
    final query = supabase.from('profiles').select();

    final response = filterRole != null && filterRole != 'All'
        ? await query.eq('role', filterRole)
        : await query;

    return List<Map<String, dynamic>>.from(response as List).reversed.toList();
  },
);

final adminProvider = Provider<AdminService>((ref) {
  return AdminService(ref);
});

class AdminService {
  final Ref _ref;
  AdminService(this._ref);

  SupabaseClient get _supabase => _ref.read(supabaseClientProvider);

  Future<void> createUser({
    required String name,
    required String username,
    required String password,
    required String role,
  }) async {
    final email = '${username.toLowerCase().trim()}@helpdesk.com';

    final exists = await _supabase
        .from('profiles')
        .select('id')
        .eq('username', username.toLowerCase().trim())
        .maybeSingle();

    if (exists != null) {
      throw Exception('Username sudah terdaftar');
    }

    late AuthResponse response;
    try {
      response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      if (e.message.contains('already')) {
        throw Exception('Email $email sudah terdaftar. Gunakan username lain.');
      }
      throw Exception('Gagal membuat akun: ${e.message}');
    }

    if (response.user == null) {
      throw Exception('Gagal membuat akun');
    }

    await _supabase.from('profiles').upsert({
      'id': response.user!.id,
      'name': name,
      'username': username.toLowerCase().trim(),
      'role': role,
    });
  }

  Future<void> deleteUser(String userId) async {
    await _supabase.from('profiles').delete().eq('id', userId);
  }

  Future<void> changeUserRole(String userId, String newRole) async {
    await _supabase.from('profiles').update({'role': newRole}).eq('id', userId);
  }
}
