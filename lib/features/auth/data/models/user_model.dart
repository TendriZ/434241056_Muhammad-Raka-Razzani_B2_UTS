/// Model Layer - Framework-specific representation (Supabase)
/// Converts between database/API format and domain entities
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required String id,
    required String fullName,
    required String username,
    required String email,
    required String role,
    required DateTime createdAt,
  }) : super(
    id: id,
    fullName: fullName,
    username: username,
    email: email,
    role: role,
    createdAt: createdAt,
  );

  /// Convert from JSON (dari Supabase API)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert ke JSON untuk dikirim ke Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'email': email,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert entity ke model
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      fullName: entity.fullName,
      username: entity.username,
      email: entity.email,
      role: entity.role,
      createdAt: entity.createdAt,
    );
  }

  /// Copy with modifications
  UserModel copyWith({
    String? id,
    String? fullName,
    String? username,
    String? email,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
