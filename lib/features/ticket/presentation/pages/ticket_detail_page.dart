import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/ticket_provider.dart';

class TicketDetailPage extends ConsumerWidget {
  final String ticketId;

  const TicketDetailPage({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketAsync = ref.watch(ticketDetailProvider(ticketId));
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tiket'),
      ),
      body: ticketAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (ticket) {
          if (ticket == null) {
            return const Center(child: Text('Tiket tidak ditemukan.'));
          }

          final role = profileAsync.value?['role'] ?? 'user';
          final canUpdateStatus = (role == 'admin' || role == 'helpdesk');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informasi Masalah',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID Tiket: $ticketId',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Judul: ${ticket['title']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text('Deskripsi: ${ticket['description']}'),
                        const SizedBox(height: 16),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status: ${ticket['status'].toString().toUpperCase()}', 
                              style: TextStyle(
                                color: ticket['status'] == 'pending' ? Colors.orange 
                                     : ticket['status'] == 'on_progress' ? Colors.blue
                                     : Colors.green,
                                fontWeight: FontWeight.bold,
                              )
                            ),
                            // Bagian Helpdesk & Admin Management (FR-009) Update Status
                            if (canUpdateStatus)
                              _StatusDropdownWidget(ticketId: ticketId, currentStatus: ticket['status'])
                          ],
                        ),
                        // FR-006.4 Assign Tiket (Khusus Admin/Helpdesk)
                        if (canUpdateStatus) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ditugaskan ke: ${ticket['assigned_to'] ?? 'Belum ada'}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  // Mengambil daftar helpdesk/admin dari profiles table
                                  final supabase = ref.read(supabaseClientProvider);
                                  try {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => const Center(child: CircularProgressIndicator()),
                                    );
                                    
                                    final List<dynamic> techs = await supabase
                                        .from('profiles')
                                        .select('id, full_name, role')
                                        .inFilter('role', ['helpdesk', 'admin']);
                                    
                                    if (context.mounted) {
                                      Navigator.pop(context); // Tutup loading
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (ctx) {
                                          return ListView.builder(
                                            itemCount: techs.length,
                                            itemBuilder: (context, index) {
                                              final t = techs[index];
                                              return ListTile(
                                                leading: const Icon(Icons.person_pin),
                                                title: Text(t['full_name'] ?? 'Tanpa Nama'),
                                                subtitle: Text('Role: ${t['role']}'),
                                                onTap: () async {
                                                  Navigator.pop(ctx);
                                                  try {
                                                    await supabase.from('tickets').update({
                                                      'assigned_to': t['full_name']
                                                    }).eq('id', ticketId);
                                                    
                                                    await supabase.from('ticket_history').insert({
                                                      'ticket_id': ticketId,
                                                      'user_id': supabase.auth.currentUser!.id,
                                                      'action': 'Assigned',
                                                      'message': 'Tiket ditugaskan ke ${t['full_name']}',
                                                    });
                                                    
                                                    ref.invalidate(ticketDetailProvider(ticketId));
                                                    ref.invalidate(ticketHistoryProvider(ticketId));
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Teknisi berhasil di-assign')));
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal assign: $e')));
                                                  }
                                                }
                                              );
                                            }
                                          );
                                        }
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal Load Teknisi: $e')));
                                    }
                                  }
                                },
                                icon: const Icon(Icons.person_add, size: 18),
                                label: const Text('Assign Tiket'),
                              )
                            ],
                          )
                        ] else ...[
                          const SizedBox(height: 8),
                          const Text('Ditangani Oleh: Tim Support IT', style: TextStyle(color: Colors.grey)),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Riwayat Pembaruan Status (FR-010)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _TicketHistoryWidget(ticketId: ticketId),
                
                const SizedBox(height: 24),
                const Text('Balasan / Komentar (FR-005.5):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _CommentInputWidget(ticketId: ticketId, currentStatus: ticket['status']),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CommentInputWidget extends ConsumerStatefulWidget {
  final String ticketId;
  final String currentStatus;

  const _CommentInputWidget({required this.ticketId, required this.currentStatus});

  @override
  ConsumerState<_CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends ConsumerState<_CommentInputWidget> {
  final _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      final supabase = ref.read(supabaseClientProvider);
      
      // Simpan input asli ke history / catatan reply
      // PASTIKAN Anda MENGGANTI ATAU MENAMBAHKAN kolom notes pada tabel history ticket menjadi note atau sesuai db.
      // Berdasarkan pesan error (notes missing), mari ganti dgn insert 'note' -> di dashboard, pastikan namanya juga sejalur!
      await supabase.from('ticket_history').insert({
        'ticket_id': widget.ticketId,
        'user_id': supabase.auth.currentUser!.id,
        'action': 'Komentar',
        'message': text,
      });

      // Invalidate history sehingga ui langsung nampil pesan baru ini
      ref.invalidate(ticketHistoryProvider(widget.ticketId));

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Komentar berhasil dikirim!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengirim: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _commentController,
      decoration: InputDecoration(
        hintText: 'Tulis pesan/balasan di sini...',
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.1),
        border: const OutlineInputBorder(),
        suffixIcon: _isSending
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: _sendComment,
              ),
      ),
    );
  }
}

class _StatusDropdownWidget extends ConsumerStatefulWidget {
  final String ticketId;
  final String currentStatus;

  const _StatusDropdownWidget({
    required this.ticketId,
    required this.currentStatus,
  });

  @override
  ConsumerState<_StatusDropdownWidget> createState() => _StatusDropdownWidgetState();
}

class _StatusDropdownWidgetState extends ConsumerState<_StatusDropdownWidget> {
  late String _statusLocal;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _statusLocal = widget.currentStatus;
  }

  @override
  void didUpdateWidget(covariant _StatusDropdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isUpdating && oldWidget.currentStatus != widget.currentStatus) {
      _statusLocal = widget.currentStatus;
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    if (newStatus == _statusLocal || _isUpdating) return;

    setState(() {
      _statusLocal = newStatus;
      _isUpdating = true;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);
      
      await supabase.from('tickets').update({'status': newStatus}).eq('id', widget.ticketId);
      
      await supabase.from('ticket_history').insert({
        'ticket_id': widget.ticketId,
        'user_id': supabase.auth.currentUser!.id,
        'action': 'Update Status',
        'message': 'Status diubah ke $newStatus',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status Tiket Berhasil Diupdate! (FR-006.3)')),
        );
      }

      ref.invalidate(ticketDetailProvider(widget.ticketId));
      ref.invalidate(ticketHistoryProvider(widget.ticketId));
      ref.invalidate(ticketsProvider); 
      ref.invalidate(ticketStatsProvider); 
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusLocal = widget.currentStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah status: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUpdating) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    
    return DropdownButton<String>(
      value: _statusLocal,
      items: const [
        DropdownMenuItem(value: 'pending', child: Text('Pending')),
        DropdownMenuItem(value: 'on_progress', child: Text('Diproses')),
        DropdownMenuItem(value: 'resolved', child: Text('Selesai')),
      ],
      onChanged: (newStatus) {
        if (newStatus != null) {
          _updateStatus(newStatus);
        }
      },
    );
  }
}

// Komponen history yang dinamis memanfaatkan Riverpod Provider
class _TicketHistoryWidget extends ConsumerWidget {
  final String ticketId;

  const _TicketHistoryWidget({required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(ticketHistoryProvider(ticketId));

    return historyAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Gagal muat history: $e'),
      data: (records) {
        if (records.isEmpty) {
          return const Text('Belum ada riwayat aktivitas pada tiket ini.', style: TextStyle(color: Colors.grey));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final log = records[index];
            return ListTile(
              leading: Icon(
                log['status'] == 'resolved' ? Icons.check_circle : Icons.update,
                color: log['status'] == 'resolved' ? Colors.green : Colors.blue,
              ),
              title: Text('${log['action']} · Status: ${log['status'] ?? '-'}'),
              subtitle: Text(log['message'] ?? 'Tanpa Catatan'),
              trailing: Text(
                log['created_at'].toString().substring(0, 16).replaceAll('T', '\n'),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                textAlign: TextAlign.end,
              ),
            );
          },
        );
      },
    );
  }
}


