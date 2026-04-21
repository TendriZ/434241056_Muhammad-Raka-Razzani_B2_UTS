/// Ticket Repository Implementation
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../datasources/ticket_remote_datasource.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketRemoteDataSource remoteDataSource;

  TicketRepositoryImpl({required this.remoteDataSource});

  // FIX: helper getter untuk ambil user ID dari Supabase auth
  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  Future<TicketEntity> createTicket({
    required String title,
    required String description,
  }) async {
    if (title.isEmpty || description.isEmpty) {
      throw Exception('Title dan description tidak boleh kosong');
    }
    if (_currentUserId.isEmpty) {
      throw Exception('User tidak terautentikasi');
    }

    return await remoteDataSource.createTicket(
      userId: _currentUserId,
      title: title,
      description: description,
    );
  }

  @override
  Future<List<TicketEntity>> getTickets({
    String? userId,
    String? role,
  }) async {
    return await remoteDataSource.getTickets(userId: userId, role: role);
  }

  @override
  Future<TicketEntity?> getTicketById({required String ticketId}) async {
    if (ticketId.isEmpty) throw Exception('Ticket ID tidak boleh kosong');
    return await remoteDataSource.getTicketById(ticketId: ticketId);
  }

  @override
  Future<bool> updateTicketStatus({
    required String ticketId,
    required String newStatus,
  }) async {
    if (ticketId.isEmpty || newStatus.isEmpty) {
      throw Exception('Ticket ID dan status tidak boleh kosong');
    }
    return await remoteDataSource.updateTicketStatus(
      ticketId: ticketId,
      newStatus: newStatus,
    );
  }

  @override
  Future<bool> assignTicket({
    required String ticketId,
    required String assignedTo,
  }) async {
    if (ticketId.isEmpty || assignedTo.isEmpty) {
      throw Exception('Ticket ID dan assigned user tidak boleh kosong');
    }
    return await remoteDataSource.assignTicket(
      ticketId: ticketId,
      assignedTo: assignedTo,
    );
  }

  @override
  Future<bool> addTicketComment({
    required String ticketId,
    required String message,
  }) async {
    if (ticketId.isEmpty || message.isEmpty) {
      throw Exception('Ticket ID dan message tidak boleh kosong');
    }
    // FIX: ambil user ID dari Supabase auth, bukan hardcoded ''
    if (_currentUserId.isEmpty) {
      throw Exception('User tidak terautentikasi');
    }
    return await remoteDataSource.addTicketComment(
      ticketId: ticketId,
      userId: _currentUserId,
      message: message,
    );
  }

  @override
  Future<List<TicketHistoryEntity>> getTicketHistory({
    required String ticketId,
  }) async {
    if (ticketId.isEmpty) throw Exception('Ticket ID tidak boleh kosong');
    return await remoteDataSource.getTicketHistory(ticketId: ticketId);
  }

  @override
  Future<Map<String, int>> getTicketStatistics({String? userId}) async {
    return await remoteDataSource.getTicketStatistics(userId: userId);
  }

  @override
  Future<String> uploadTicketAttachment({
    required String ticketId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    if (ticketId.isEmpty || fileBytes.isEmpty || fileName.isEmpty) {
      throw Exception('Ticket ID, file, dan nama file tidak boleh kosong');
    }
    return await remoteDataSource.uploadTicketAttachment(
      ticketId: ticketId,
      fileBytes: fileBytes,
      fileName: fileName,
    );
  }

  @override
  Future<bool> deleteTicket({required String ticketId}) async {
    if (ticketId.isEmpty) throw Exception('Ticket ID tidak boleh kosong');
    return await remoteDataSource.deleteTicket(ticketId: ticketId);
  }
}