import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

// Provider untuk mengakses AuthNotifier di lapisan UI
final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<User?> {
  late final SupabaseClient _supabase;

  @override
  FutureOr<User?> build() {
    _supabase = ref.watch(supabaseClientProvider);
    _checkSession();
    return _supabase.auth.currentUser;
  }

  // Cek apakah user sudah pernah login sebelumnya
  void _checkSession() {
    _supabase.auth.onAuthStateChange.listen((event) {
      state = AsyncData(event.session?.user);
    });
  }

  // Register FR-003
  Future<void> register({
    required String name,
    required String username,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      // Supabase default butuh email. Kita akali dengan username@helpdesk.com
      final emailFormat = '${username.toLowerCase().trim()}@helpdesk.com';
      
      final response = await _supabase.auth.signUp(
        email: emailFormat,
        password: password,
      );
      
      // Jika berhasil signUp, masukkan data profilenya ke tabel 'profiles'
      if (response.user != null) {
        await _supabase.from('profiles').insert({
          'id': response.user!.id,
          'name': name,
          'username': username.toLowerCase().trim(),
          'role': 'user',
        });
      }
      
      state = AsyncData(response.user);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // Login FR-001
  Future<String?> login({
    required String username,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final emailFormat = '${username.toLowerCase().trim()}@helpdesk.com';
      
      final response = await _supabase.auth.signInWithPassword(
        email: emailFormat,
        password: password,
      );
      
      state = AsyncData(response.user);

      if (response.user != null) {
        // Ambil data role dari tabel profiles
        final profileData = await _supabase
            .from('profiles')
            .select('role')
            .eq('id', response.user!.id)
            .maybeSingle();
            
        if (profileData != null && profileData.containsKey('role')) {
          return profileData['role'] as String;
        }
      }
      return 'user'; // default role
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // Logout FR-002
  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await _supabase.auth.signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
