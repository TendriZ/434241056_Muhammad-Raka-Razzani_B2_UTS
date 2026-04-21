/// Remote Data Source - Communication dengan Supabase API
/// Handles all network/database operations untuk auth
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// FR-001: Login
  Future<UserModel> login({required String username, required String password});

  /// FR-003: Register
  Future<UserModel> register({
    required String fullName,
    required String username,
    required String password,
  });

  /// FR-002: Logout
  Future<void> logout();

  /// FR-004: Request password reset
  Future<bool> requestPasswordReset({required String email});

  /// FR-004: Reset password with token
  Future<bool> resetPassword({required String token, required String newPassword});

  /// Get current session user
  Future<UserModel?> getCurrentUser();

  /// Check if username already exists
  Future<bool> usernameExists({required String username});

  /// Verify user role di backend
  Future<bool> verifyUserRole({required String userId, required String expectedRole});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      // Convert username to email format untuk Supabase Auth
      final email = '${username.toLowerCase().trim()}@helpdesk.com';

      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed: User data not found');
      }

      // Fetch user profile dari database sesuai dengan user ID
      final profileData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (profileData == null) {
        throw Exception('User profile not found in database');
      }

      return UserModel.fromJson(profileData);
    } on AuthException catch (e) {
      throw Exception('Login error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during login: $e');
    }
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String username,
    required String password,
  }) async {
    try {
      // Validate: Check if username sudah ada
      final exists = await usernameExists(username: username);
      if (exists) {
        throw Exception('Username sudah terdaftar. Silakan gunakan username lain.');
      }

      // Validate: Password strength
      if (password.length < 6) {
        throw Exception('Password minimal 6 karakter');
      }

      final email = '${username.toLowerCase().trim()}@helpdesk.com';

      // Sign up di Supabase Auth
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Registration failed: Unable to create account');
      }

      // Insert profile ke database
      final profileData = {
        'id': response.user!.id,
        'full_name': fullName,
        'username': username.toLowerCase().trim(),
        'email': email,
        'role': 'user', // Default role untuk new users
        'created_at': DateTime.now().toIso8601String(),
      };

      await supabaseClient.from('profiles').insert(profileData);

      return UserModel.fromJson(profileData);
    } on AuthException catch (e) {
      throw Exception('Registration error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during registration: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }

  @override
  Future<bool> requestPasswordReset({required String email}) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(email);
      return true;
    } on AuthException catch (e) {
      throw Exception('Password reset error: ${e.message}');
    }
  }

  @override
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      // Implementasi ini bergantung pada flow Supabase
      // Biasanya setelah user klik link di email, mereka di-redirect dengan token
      final response = await supabaseClient.auth.verifyOTP(
        token: token,
        type: OtpType.recovery,
      );

      if (response.user == null) {
        throw Exception('Token verification failed');
      }

      // Update password
      await supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return true;
    } on AuthException catch (e) {
      throw Exception('Password reset verification error: ${e.message}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) return null;

      final profileData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .maybeSingle();

      if (profileData == null) return null;

      return UserModel.fromJson(profileData);
    } catch (e) {
      throw Exception('Error fetching current user: $e');
    }
  }

  @override
  Future<bool> usernameExists({required String username}) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select('id')
          .eq('username', username.toLowerCase().trim())
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Error checking username: $e');
    }
  }

  @override
  Future<bool> verifyUserRole({
    required String userId,
    required String expectedRole,
  }) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return false;

      final role = response['role'] as String?;
      return role == expectedRole;
    } catch (e) {
      throw Exception('Error verifying user role: $e');
    }
  }
}
