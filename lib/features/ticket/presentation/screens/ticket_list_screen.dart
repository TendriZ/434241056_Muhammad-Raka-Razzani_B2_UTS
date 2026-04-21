/// Ticket List Screen - menampilkan semua tiket dengan filter role
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/ticket_entity.dart';
import '../bloc/ticket_bloc.dart';

class TicketListScreen extends StatefulWidget {
  final String? role;
  final String? userId;

  const TicketListScreen({
    Key? key,
    this.role,
    this.userId,
  }) : super(key: key);

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  late TicketBloc _ticketBloc;
  String _selectedStatus = 'all'; // all, pending, on_progress, resolved

  @override
  void initState() {
    super.initState();
    _ticketBloc = context.read<TicketBloc>();
    _loadTickets();
  }

  void _loadTickets() {
    _ticketBloc.add(
      FetchTicketsEvent(
        userId: widget.userId,
        role: widget.role,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Ticketing Helpdesk'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTickets,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tab
          _buildFilterTab(),
          // Ticket List
          Expanded(
            child: BlocBuilder<TicketBloc, TicketState>(
              builder: (context, state) {
                if (state is TicketLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TicketsLoaded) {
                  final filteredTickets = _filterTickets(state.tickets);
                  
                  if (filteredTickets.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada tiket',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = filteredTickets[index];
                      return _buildTicketCard(context, ticket);
                    },
                  );
                } else if (state is TicketError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.message}',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.role != 'helpdesk' && widget.role != 'admin'
          ? FloatingActionButton(
              onPressed: () => _navigateToCreateTicket(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFilterTab() {
    final filters = [
      ('all', 'Semua', Colors.grey),
      ('pending', 'Pending', Colors.orange),
      ('on_progress', 'Proses', Colors.blue),
      ('resolved', 'Selesai', Colors.green),
    ];

    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedStatus == filter.$1;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(filter.$2),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedStatus = filter.$1);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, TicketEntity ticket) {
    final statusColor = _getStatusColor(ticket.status);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          ticket.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              ticket.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ticket.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(ticket.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _navigateToTicketDetail(context, ticket.id),
      ),
    );
  }

  List<TicketEntity> _filterTickets(List<TicketEntity> tickets) {
    if (_selectedStatus == 'all') {
      return tickets;
    }
    return tickets.where((ticket) => ticket.status == _selectedStatus).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'on_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes} menit lalu';
      }
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToCreateTicket(BuildContext context) {
    Navigator.of(context).pushNamed('/ticket/create');
  }

  void _navigateToTicketDetail(BuildContext context, String ticketId) {
    Navigator.of(context).pushNamed(
      '/ticket/detail',
      arguments: ticketId,
    );
  }
}
