/// Abstract Repository Interface untuk Ticket (Domain Layer)
import '../entities/ticket_entity.dart';

abstract class TicketRepository {
  /// FR-005: Create new ticket
  /// Returns created ticket
  Future<TicketEntity> createTicket({
    required String title,
    required String description,
  });

  /// FR-006: Get tickets dengan role-based filtering
  /// User hanya lihat tiket mereka, admin/helpdesk lihat semua
  Future<List<TicketEntity>> getTickets({
    String? userId,
    String? role,
  });

  /// FR-006: Get single ticket detail
  Future<TicketEntity?> getTicketById({required String ticketId});

  /// FR-006.3: Update ticket status
  /// Only admin/helpdesk bisa melakukan ini
  /// Requires backend verification
  Future<bool> updateTicketStatus({
    required String ticketId,
    required String newStatus,
  });

  /// FR-006.4: Assign ticket ke admin/helpdesk
  Future<bool> assignTicket({
    required String ticketId,
    required String assignedTo,
  });

  /// FR-007: Add comment/update ke ticket
  Future<bool> addTicketComment({
    required String ticketId,
    required String message,
  });

  /// FR-010: Get ticket history/comments
  Future<List<TicketHistoryEntity>> getTicketHistory({
    required String ticketId,
  });

  /// FR-008: Get statistics
  Future<Map<String, int>> getTicketStatistics({String? userId});

  /// FR-005.2: Upload file/image untuk ticket
  /// Returns file path atau URL di storage
  Future<String> uploadTicketAttachment({
    required String ticketId,
    required List<int> fileBytes,
    required String fileName,
  });

  /// Delete ticket (admin only)
  Future<bool> deleteTicket({required String ticketId});
}
