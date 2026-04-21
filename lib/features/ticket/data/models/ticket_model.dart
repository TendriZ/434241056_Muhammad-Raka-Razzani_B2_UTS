/// Ticket Models - Framework-specific (Supabase) representation
import '../../domain/entities/ticket_entity.dart';

class TicketModel extends TicketEntity {
  const TicketModel({
    required String id,
    required String userId,
    required String title,
    required String description,
    required String status,
    String? assignedTo,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super(
    id: id,
    userId: userId,
    title: title,
    description: description,
    status: status,
    assignedTo: assignedTo,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      assignedTo: json['assigned_to'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'status': status,
      'assigned_to': assignedTo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory TicketModel.fromEntity(TicketEntity entity) {
    return TicketModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.description,
      status: entity.status,
      assignedTo: entity.assignedTo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  TicketModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? status,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TicketHistoryModel extends TicketHistoryEntity {
  const TicketHistoryModel({
    required String id,
    required String ticketId,
    required String userId,
    required String action,
    required String message,
    String? status,
    required DateTime createdAt,
  }) : super(
    id: id,
    ticketId: ticketId,
    userId: userId,
    action: action,
    message: message,
    status: status,
    createdAt: createdAt,
  );

  factory TicketHistoryModel.fromJson(Map<String, dynamic> json) {
    return TicketHistoryModel(
      id: json['id'] as String? ?? '',
      ticketId: json['ticket_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      action: json['action'] as String? ?? '',
      message: json['message'] as String? ?? '',
      status: json['status'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'user_id': userId,
      'action': action,
      'message': message,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TicketHistoryModel.fromEntity(TicketHistoryEntity entity) {
    return TicketHistoryModel(
      id: entity.id,
      ticketId: entity.ticketId,
      userId: entity.userId,
      action: entity.action,
      message: entity.message,
      status: entity.status,
      createdAt: entity.createdAt,
    );
  }
}
