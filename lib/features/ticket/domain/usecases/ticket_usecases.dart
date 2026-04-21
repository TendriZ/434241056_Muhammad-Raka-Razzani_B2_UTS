/// Use Cases - Business Logic Layer
import '../../domain/entities/ticket_entity.dart';
import '../../domain/repositories/ticket_repository.dart';

// Create Ticket Use Case
class CreateTicketUseCase {
  final TicketRepository repository;

  CreateTicketUseCase({required this.repository});

  Future<TicketEntity> call({
    required String title,
    required String description,
  }) async {
    return await repository.createTicket(
      title: title,
      description: description,
    );
  }
}

// Get Tickets Use Case (dengan filtering)
class GetTicketsUseCase {
  final TicketRepository repository;

  GetTicketsUseCase({required this.repository});

  Future<List<TicketEntity>> call({
    String? userId,
    String? role,
  }) async {
    return await repository.getTickets(userId: userId, role: role);
  }
}

// Get Ticket Detail Use Case
class GetTicketDetailUseCase {
  final TicketRepository repository;

  GetTicketDetailUseCase({required this.repository});

  Future<TicketEntity?> call({required String ticketId}) async {
    return await repository.getTicketById(ticketId: ticketId);
  }
}

// Update Ticket Status Use Case
class UpdateTicketStatusUseCase {
  final TicketRepository repository;

  UpdateTicketStatusUseCase({required this.repository});

  Future<bool> call({
    required String ticketId,
    required String newStatus,
  }) async {
    return await repository.updateTicketStatus(
      ticketId: ticketId,
      newStatus: newStatus,
    );
  }
}

// Assign Ticket Use Case
class AssignTicketUseCase {
  final TicketRepository repository;

  AssignTicketUseCase({required this.repository});

  Future<bool> call({
    required String ticketId,
    required String assignedTo,
  }) async {
    return await repository.assignTicket(
      ticketId: ticketId,
      assignedTo: assignedTo,
    );
  }
}

// Add Ticket Comment Use Case
class AddTicketCommentUseCase {
  final TicketRepository repository;

  AddTicketCommentUseCase({required this.repository});

  Future<bool> call({
    required String ticketId,
    required String message,
  }) async {
    return await repository.addTicketComment(
      ticketId: ticketId,
      message: message,
    );
  }
}

// Get Ticket History Use Case
class GetTicketHistoryUseCase {
  final TicketRepository repository;

  GetTicketHistoryUseCase({required this.repository});

  Future<List<TicketHistoryEntity>> call({required String ticketId}) async {
    return await repository.getTicketHistory(ticketId: ticketId);
  }
}

// Get Ticket Statistics Use Case
class GetTicketStatisticsUseCase {
  final TicketRepository repository;

  GetTicketStatisticsUseCase({required this.repository});

  Future<Map<String, int>> call({String? userId}) async {
    return await repository.getTicketStatistics(userId: userId);
  }
}

// Upload Ticket Attachment Use Case
class UploadTicketAttachmentUseCase {
  final TicketRepository repository;

  UploadTicketAttachmentUseCase({required this.repository});

  Future<String> call({
    required String ticketId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    return await repository.uploadTicketAttachment(
      ticketId: ticketId,
      fileBytes: fileBytes,
      fileName: fileName,
    );
  }
}

// Delete Ticket Use Case
class DeleteTicketUseCase {
  final TicketRepository repository;

  DeleteTicketUseCase({required this.repository});

  Future<bool> call({required String ticketId}) async {
    return await repository.deleteTicket(ticketId: ticketId);
  }
}
