/// Entity Layer - Domain Purity (Independent of any framework)
/// Represents a User in the application
class UserEntity {
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String role; // 'user', 'admin', 'helpdesk'
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          username == other.username &&
          email == other.email &&
          role == other.role &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      fullName.hashCode ^
      username.hashCode ^
      email.hashCode ^
      role.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'UserEntity(id: $id, fullName: $fullName, username: $username, email: $email, role: $role, createdAt: $createdAt)';
  }
}
