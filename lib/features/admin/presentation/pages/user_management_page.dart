import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';

// Provider untuk mengambil daftar users dengan filter
final usersProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String?>((ref, filterRole) async {
  final supabase = ref.watch(supabaseClientProvider);
  final query = supabase.from('profiles').select();

  // Apply filter role jika ada
  final response = filterRole != null && filterRole != 'All'
      ? await query.eq('role', filterRole)
      : await query;

  return List<Map<String, dynamic>>.from(response as List).reversed.toList();
});

class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage> {
  String _selectedRoleFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider(_selectedRoleFilter));
    final supabase = ref.watch(supabaseClientProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(usersProvider(_selectedRoleFilter)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                // Role Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'admin', 'helpdesk', 'user'].map((role) {
                      final isSelected = _selectedRoleFilter == role;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(role == 'All' ? 'Semua' : role.toUpperCase()),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedRoleFilter = role;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                // Search Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan nama atau username...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ],
            ),
          ),

          // User List
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Terjadi Kesalahan: $err')),
              data: (users) {
                // Filter by search query
                final filteredUsers = _searchQuery.isEmpty
                    ? users
                    : users.where((user) {
                        final name = (user['full_name'] ?? '').toLowerCase();
                        final username = (user['username'] ?? '').toLowerCase();
                        return name.contains(_searchQuery) || username.contains(_searchQuery);
                      }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(child: Text('Tidak ada pengguna ditemukan.'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(usersProvider(_selectedRoleFilter));
                  },
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final currentRole = user['role'] ?? 'user';
                      final isCurrentAdmin = user['id'] == supabase.auth.currentUser?.id;

                      Color roleColor = currentRole == 'admin'
                          ? Colors.redAccent
                          : (currentRole == 'helpdesk' ? Colors.amber : Colors.blueGrey);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: roleColor.withValues(alpha: 0.2),
                            child: Icon(Icons.person, color: roleColor),
                          ),
                          title: Text(
                            user['full_name'] ?? 'Tanpa Nama',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('@${user['username'] ?? 'username'}'),
                          trailing: isCurrentAdmin
                              ? Chip(
                                  label: const Text('Anda', style: TextStyle(fontSize: 11)),
                                  backgroundColor: Colors.green.shade100,
                                )
                              : Icon(
                                  Icons.more_vert,
                                  color: roleColor,
                                ),
                          children: [
                            // Detail User
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow('User ID', user['id'] ?? '-'),
                                  const SizedBox(height: 8),
                                  _buildDetailRow('Username', '@${user['username'] ?? '-'}'),
                                  const SizedBox(height: 8),
                                  _buildDetailRow('Email', user['email'] ?? '-'),
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    'Role',
                                    currentRole.toUpperCase(),
                                    valueColor: roleColor,
                                  ),
                                  const SizedBox(height: 16),

                                  // Role Change Buttons
                                  if (!isCurrentAdmin) ...[
                                    const Text(
                                      'Ubah Role:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      children: ['user', 'helpdesk', 'admin'].map((role) {
                                        final isCurrent = currentRole == role;
                                        return ElevatedButton(
                                          onPressed: isCurrent
                                              ? null
                                              : () => _changeUserRole(user['id'], role),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isCurrent
                                                ? Colors.grey.shade300
                                                : (role == 'admin'
                                                    ? Colors.redAccent
                                                    : (role == 'helpdesk'
                                                        ? Colors.amber
                                                        : Colors.blue)),
                                            foregroundColor: isCurrent ? Colors.grey : Colors.white,
                                          ),
                                          child: Text(role.toUpperCase()),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: valueColor,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _changeUserRole(String userId, String newRole) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final supabase = ref.read(supabaseClientProvider);
      await supabase.from('profiles').update({'role': newRole}).eq('id', userId);

      if (mounted) {
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Role berhasil diubah menjadi $newRole'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(usersProvider(_selectedRoleFilter));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah role: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
