/// Remote Data Source untuk Ticket - komunikasi dengan Supabase
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_model.dart';

abstract class TicketRemoteDataSource {
  Future<TicketModel> createTicket({
    required String userId,
    required String title,
    required String description,
  });

  Future<List<TicketModel>> getTickets({
    String? userId,
    String? role,
  });

  Future<TicketModel?> getTicketById({required String ticketId});

  Future<bool> updateTicketStatus({
    required String ticketId,
    required String newStatus,
  });

  Future<bool> assignTicket({
    required String ticketId,
    required String assignedTo,
  });

  Future<bool> addTicketComment({
    required String ticketId,
    required String userId,
    required String message,
  });

  Future<List<TicketHistoryModel>> getTicketHistory({
    required String ticketId,
  });

  Future<Map<String, int>> getTicketStatistics({String? userId});

  Future<String> uploadTicketAttachment({
    required String ticketId,
    required List<int> fileBytes,
    required String fileName,
  });

  Future<bool> deleteTicket({required String ticketId});
}

class TicketRemoteDataSourceImpl implements TicketRemoteDataSource {
  final SupabaseClient supabaseClient;

  TicketRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<TicketModel> createTicket({
    required String userId,
    required String title,
    required String description,
  }) async {
    try {
      final response = await supabaseClient.from('tickets').insert({
        'user_id': userId,
        'title': title,
        'description': description,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      return TicketModel.fromJson(response);
    } catch (e) {
      throw Exception('Error creating ticket: $e');
    }
  }

  @override
  Future<List<TicketModel>> getTickets({
    String? userId,
    String? role,
  }) async {
    try {
      var query = supabaseClient.from('tickets').select();

      if (role == 'user' && userId != null) {
        query = query.eq('user_id', userId);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => TicketModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching tickets: $e');
    }
  }

  @override
  Future<TicketModel?> getTicketById({required String ticketId}) async {
    try {
      final response = await supabaseClient
          .from('tickets')
          .select()
          .eq('id', ticketId)
          .maybeSingle();

      if (response == null) return null;
      return TicketModel.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching ticket detail: $e');
    }
  }

  @override
  Future<bool> updateTicketStatus({
    required String ticketId,
    required String newStatus,
  }) async {
    try {
      const validStatuses = ['pending', 'on_progress', 'resolved'];
      if (!validStatuses.contains(newStatus)) {
        throw Exception('Invalid status: $newStatus');
      }

      await supabaseClient.from('tickets').update({
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', ticketId);

      await supabaseClient.from('ticket_history').insert({
        'ticket_id': ticketId,
        'user_id': supabaseClient.auth.currentUser!.id,
        'action': 'Status Update',
        'message': 'Status diubah menjadi $newStatus',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      throw Exception('Error updating ticket status: $e');
    }
  }

  @override
  Future<bool> assignTicket({
    required String ticketId,
    required String assignedTo,
  }) async {
    try {
      await supabaseClient.from('tickets').update({
        'assigned_to': assignedTo,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', ticketId);

      await supabaseClient.from('ticket_history').insert({
        'ticket_id': ticketId,
        'user_id': supabaseClient.auth.currentUser!.id,
        'action': 'Assigned',
        'message': 'Tiket ditugaskan ke $assignedTo',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      throw Exception('Error assigning ticket: $e');
    }
  }

  @override
  Future<bool> addTicketComment({
    required String ticketId,
    required String userId,
    required String message,
  }) async {
    try {
      await supabaseClient.from('ticket_history').insert({
        'ticket_id': ticketId,
        'user_id': userId,
        'action': 'Comment',
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      throw Exception('Error adding comment: $e');
    }
  }

  @override
  Future<List<TicketHistoryModel>> getTicketHistory({
    required String ticketId,
  }) async {
    try {
      final response = await supabaseClient
          .from('ticket_history')
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TicketHistoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching ticket history: $e');
    }
  }

  @override
  Future<Map<String, int>> getTicketStatistics({String? userId}) async {
    try {
      var query = supabaseClient.from('tickets').select('status');

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      final response = await query;

      int total = 0, pending = 0, onProgress = 0, resolved = 0;

      for (var item in response as List) {
        total++;
        final status = item['status'] as String?;
        if (status == 'pending') pending++;
        else if (status == 'on_progress') onProgress++;
        else if (status == 'resolved') resolved++;
      }

      return {
        'total': total,
        'pending': pending,
        'on_progress': onProgress,
        'resolved': resolved,
      };
    } catch (e) {
      throw Exception('Error fetching statistics: $e');
    }
  }

  @override
  Future<String> uploadTicketAttachment({
    required String ticketId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = 'tickets/$ticketId/$timestamp-$fileName';

      // FIX: convert List<int> ke Uint8List sebelum upload
      await supabaseClient.storage
          .from('ticket-attachments')
          .uploadBinary(filePath, Uint8List.fromList(fileBytes));

      final publicUrl = supabaseClient.storage
          .from('ticket-attachments')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }

  @override
  Future<bool> deleteTicket({required String ticketId}) async {
    try {
      await supabaseClient.from('tickets').delete().eq('id', ticketId);
      return true;
    } catch (e) {
      throw Exception('Error deleting ticket: $e');
    }
  }
}