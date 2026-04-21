import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';

final usersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final response = await supabase.from('profiles').select().order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(response);
});

class UserManagementPage extends ConsumerWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);
    final supabase = ref.watch(supabaseClientProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna'),
        automaticallyImplyLeading: false,
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Terjadi Kesalahan: $err')),
        data: (users) {
          if (users.isEmpty) return const Center(child: Text('Tidak ada pengguna.'));
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(usersProvider);
            },
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final currentRole = user['role'] ?? 'user';
                final isCurrentAdmin = user['id'] == supabase.auth.currentUser?.id;

                Color roleColor = currentRole == 'admin' 
                    ? Colors.redAccent 
                    : (currentRole == 'helpdesk' ? Colors.amber : Colors.blueGrey);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: roleColor.withValues(alpha: 0.2),
                      child: Icon(Icons.person, color: roleColor),
                    ),
                    title: Text(
                      user['full_name'] ?? 'Tanpa Nama',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user['id'] ?? ''),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: roleColor.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            currentRole.toString().toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: roleColor),
                          ),
                        ),
                      ],
                    ),
                    trailing: isCurrentAdmin 
                      ? const Text('Anda', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                      : PopupMenuButton<String>(
                          onSelected: (newRole) async {
                            try {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(child: CircularProgressIndicator()),
                              );
                              
                              await supabase.from('profiles').update({'role': newRole}).eq('id', user['id']);
                              
                              if (context.mounted) {
                                Navigator.pop(context); // close dialog
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Peran diubah menjadi $newRole')));
                                ref.invalidate(usersProvider);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                Navigator.pop(context); // close dialog
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengubah peran: $e')));
                              }
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'user', child: Text('Jadikan Pengguna Biasa')),
                            PopupMenuItem(value: 'helpdesk', child: Text('Jadikan Helpdesk')),
                            PopupMenuItem(value: 'admin', child: Text('Jadikan Admin')),
                          ],
                        ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
