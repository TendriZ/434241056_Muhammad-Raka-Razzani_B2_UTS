/// Abstract Repository Interface (Domain Layer)
/// Defines contracts for authentication operations
/// Implementation details are in data layer
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// FR-001: Login dengan username dan password
  /// Returns User entity jika berhasil
  /// Throws exception jika gagal
  Future<UserEntity> login({
    required String username,
    required String password,
  });

  /// FR-003: Register dengan data lengkap
  /// Validates duplicate username di database
  /// Returns User entity yang baru dibuat
  /// Throws DuplicateUsernameException jika username sudah ada
  Future<UserEntity> register({
    required String fullName,
    required String username,
    required String password,
  });

  /// FR-002: Logout - Clear session
  Future<void> logout();

  /// FR-004: Request password reset
  /// Sends email dengan reset link
  /// Returns success boolean
  Future<bool> requestPasswordReset({required String email});

  /// FR-004: Verify reset token dan set password baru
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Get current logged in user
  /// Returns null jika tidak ada session
  Future<UserEntity?> getCurrentUser();

  /// Verify user role (backend validation)
  Future<bool> verifyUserRole({
    required String userId,
    required String expectedRole,
  });
}
