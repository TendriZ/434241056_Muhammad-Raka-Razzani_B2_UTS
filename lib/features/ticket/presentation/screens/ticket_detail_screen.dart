/// Ticket Detail Screen - menampilkan detail tiket lengkap dengan history
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/ticket_entity.dart';
import '../bloc/ticket_bloc.dart';

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  late TicketBloc _ticketBloc;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ticketBloc = context.read<TicketBloc>();
    _loadTicketDetail();
  }

  void _loadTicketDetail() {
    _ticketBloc.add(FetchTicketDetailEvent(ticketId: widget.ticketId));
    _ticketBloc.add(FetchTicketHistoryEvent(ticketId: widget.ticketId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tiket'),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTicketDetail),
        ],
      ),
      body: BlocBuilder<TicketBloc, TicketState>(
        builder: (context, state) {
          if (state is TicketLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TicketDetailLoaded) {
            return _buildDetailContent(context, state.ticket);
          } else if (state is TicketError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, TicketEntity ticket) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(ticket),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTicketInfo(ticket),
                const SizedBox(height: 24),
                _buildStatusSection(context, ticket),
                const SizedBox(height: 24),
                _buildHistorySection(),
                const SizedBox(height: 24),
                _buildCommentSection(context, ticket),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(TicketEntity ticket) {
    return Container(
      color: Colors.blue[50],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ticket.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Tiket #${ticket.id.substring(0, 8)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildTicketInfo(TicketEntity ticket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Informasi Tiket',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildInfoRow('Status', ticket.status),
        _buildInfoRow('Dibuat', _formatDateTime(ticket.createdAt)),
        if (ticket.updatedAt != null)
          _buildInfoRow('Diperbarui', _formatDateTime(ticket.updatedAt!)),
        if (ticket.assignedTo != null)
          _buildInfoRow('Ditugaskan ke', ticket.assignedTo!),
        const SizedBox(height: 16),
        const Text('Deskripsi',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(ticket.description),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, TicketEntity ticket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Status & Aksi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        BlocBuilder<TicketBloc, TicketState>(
          builder: (context, state) {
            final isLoading = state is TicketLoading;
            return Wrap(
              spacing: 8,
              children: [
                if (ticket.status != 'on_progress')
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : () => _updateStatus(context, 'on_progress'),
                    icon: const Icon(Icons.loop),
                    label: const Text('Mulai'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                if (ticket.status != 'resolved')
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : () => _updateStatus(context, 'resolved'),
                    icon: const Icon(Icons.check),
                    label: const Text('Selesai'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Riwayat',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        BlocBuilder<TicketBloc, TicketState>(
          builder: (context, state) {
            if (state is TicketHistoryLoaded) {
              if (state.history.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Belum ada riwayat'),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.history.length,
                itemBuilder: (context, index) {
                  return _buildHistoryItem(state.history[index]);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildHistoryItem(TicketHistoryEntity history) {
    final isStatusUpdate = history.action == 'Status Update';
    final isAssigned = history.action == 'Assigned';
    // FIX: hapus 'isComment' yang tidak dipakai — langsung pakai else di bawah

    Color badgeColor;
    Color textColor;
    String badgeLabel;

    if (isStatusUpdate) {
      badgeColor = Colors.blue[100]!;
      textColor = Colors.blue;
      badgeLabel = 'Status Update';
    } else if (isAssigned) {
      badgeColor = Colors.purple[100]!;
      textColor = Colors.purple;
      badgeLabel = 'Assigned';
    } else {
      badgeColor = Colors.green[100]!;
      textColor = Colors.green;
      badgeLabel = 'Comment';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(badgeLabel,
                      style: TextStyle(fontSize: 12, color: textColor)),
                ),
                const Spacer(),
                Text(_formatDateTime(history.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 8),
            Text(history.message, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection(BuildContext context, TicketEntity ticket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tambah Komentar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: 'Tulis komentar Anda...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(12),
            suffixIcon: BlocBuilder<TicketBloc, TicketState>(
              builder: (context, state) {
                final isLoading = state is TicketLoading;
                return IconButton(
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send),
                  onPressed: isLoading ? null : () => _addComment(context),
                );
              },
            ),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  void _updateStatus(BuildContext context, String newStatus) {
    context.read<TicketBloc>().add(
          UpdateTicketStatusEvent(ticketId: widget.ticketId, newStatus: newStatus));
  }

  void _addComment(BuildContext context) {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Komentar tidak boleh kosong')));
      return;
    }
    context.read<TicketBloc>().add(
          AddTicketCommentEvent(
              ticketId: widget.ticketId, message: _commentController.text.trim()));
    _commentController.clear();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}