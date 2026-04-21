/// Repository Implementation - Bridge antara domain dan data layer
/// Implements abstract repository dengan concrete implementations
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> login({
    required String username,
    required String password,
  }) async {
    try {
      // Validasi input
      if (username.isEmpty || password.isEmpty) {
        throw Exception('Username dan password tidak boleh kosong');
      }

      // Call datasource (network layer)
      final userModel = await remoteDataSource.login(
        username: username,
        password: password,
      );

      // Return as entity (domain layer)
      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> register({
    required String fullName,
    required String username,
    required String password,
  }) async {
    try {
      // Validasi input
      if (fullName.isEmpty || username.isEmpty || password.isEmpty) {
        throw Exception('Semua field harus diisi');
      }

      if (password.length < 6) {
        throw Exception('Password minimal 6 karakter');
      }

      // Call datasource
      final userModel = await remoteDataSource.register(
        fullName: fullName,
        username: username,
        password: password,
      );

      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> requestPasswordReset({required String email}) async {
    try {
      if (email.isEmpty) {
        throw Exception('Email tidak boleh kosong');
      }

      return await remoteDataSource.requestPasswordReset(email: email);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      if (token.isEmpty || newPassword.isEmpty) {
        throw Exception('Token dan password baru tidak boleh kosong');
      }

      if (newPassword.length < 6) {
        throw Exception('Password minimal 6 karakter');
      }

      return await remoteDataSource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      return await remoteDataSource.getCurrentUser();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> verifyUserRole({
    required String userId,
    required String expectedRole,
  }) async {
    try {
      return await remoteDataSource.verifyUserRole(
        userId: userId,
        expectedRole: expectedRole,
      );
    } catch (e) {
      rethrow;
    }
  }
}
