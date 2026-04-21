/// Ticket Entity - Domain Layer representation
class TicketEntity {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String status; // 'pending', 'on_progress', 'resolved'
  final String? assignedTo; // Teknisi/helpdesk yang menangani
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TicketEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    this.assignedTo,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          title == other.title &&
          description == other.description &&
          status == other.status &&
          assignedTo == other.assignedTo &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      title.hashCode ^
      description.hashCode ^
      status.hashCode ^
      assignedTo.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'TicketEntity(id: $id, userId: $userId, title: $title, status: $status)';
  }
}

/// Ticket History/Comment Entity - For tracking changes and comments
class TicketHistoryEntity {
  final String id;
  final String ticketId;
  final String userId;
  final String action; // 'Status Update', 'Comment', 'Assigned'
  final String message;
  final String? status; // Status lama atau baru
  final DateTime createdAt;

  const TicketHistoryEntity({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.action,
    required this.message,
    this.status,
    required this.createdAt,
  });

  @override
  String toString() {
    return 'TicketHistoryEntity(id: $id, ticketId: $ticketId, action: $action)';
  }
}
