/// Ticket Models - Framework-specific (Supabase) representation
import '../../domain/entities/ticket_entity.dart';

class TicketModel extends TicketEntity {
  const TicketModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.status,
    super.assignedTo,
    super.priority = 'medium',
    required super.createdAt,
    super.updatedAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      assignedTo: json['assigned_to'] as String?,
      priority: json['priority'] as String? ?? 'medium',
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
      'priority': priority,
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
      priority: entity.priority,
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
    String? priority,
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
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TicketHistoryModel extends TicketHistoryEntity {
  const TicketHistoryModel({
    required super.id,
    required super.ticketId,
    required super.userId,
    required super.action,
    required super.message,
    super.status,
    required super.createdAt,
  });

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
