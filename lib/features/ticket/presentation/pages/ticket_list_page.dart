import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/ticket_provider.dart';

class TicketListPage extends ConsumerWidget {
  const TicketListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketsProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final role = profileAsync.value?['role'] ?? 'user';

    return Scaffold(
      appBar: AppBar(
        title: Text(role == 'user' ? 'Tiket Saya' : 'Semua Laporan Tiket'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter Tiket Belum Aktif')),
              );
            },
          ),
        ],
      ),
      body: ticketsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Terjadi Kesalahan: $err')),
        data: (tickets) {
          if (tickets.isEmpty) {
            return Center(
              child: Text(role == 'user' ? 'Belum ada tiket yang dibuat.' : 'Belum ada keluhan masuk.')
            );
          }
          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final tiket = tickets[index];
              final isPending = tiket['status'] == 'pending';
              final isOnProgress = tiket['status'] == 'on_progress';
              
              Color statusColor = isPending ? Colors.orange : (isOnProgress ? Colors.blue : Colors.green);
              IconData statusIcon = isPending ? Icons.pending_actions : (isOnProgress ? Icons.sync : Icons.check_circle);

              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withValues(alpha: 0.1),
                    child: Icon(statusIcon, color: statusColor),
                  ),
                  title: Text(
                    tiket['title'] ?? 'Tanpa Judul',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        tiket['description']?.toString().replaceAll('\n',' ') ?? '...',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      if (role != 'user')
                        Text(
                          'Pelapor ID: ${tiket['user_id']?.substring(0, 8)}...',
                          style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade400, fontWeight: FontWeight.w600),
                        )
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      tiket['status'].toString().toUpperCase(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ),
                  onTap: () {
                    context.push('/ticket/detail/${tiket['id']}');
                  },
                ),
              );
            },
          );
        }
      ),
      floatingActionButton: role == 'user' 
        ? FloatingActionButton.extended(
            onPressed: () {
              context.push('/ticket/create');
            },
            icon: const Icon(Icons.add),
            label: const Text('Buat Tiket'),
          )
        : null,
    );
  }
}

