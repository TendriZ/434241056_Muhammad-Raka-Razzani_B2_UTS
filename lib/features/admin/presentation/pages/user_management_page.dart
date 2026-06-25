import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_theme.dart';

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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: AppTheme.elevationLevel1,
        automaticallyImplyLeading: false,
        title: Text(
          'Manajemen Pengguna',
          style: AppTheme.titleLarge.copyWith(color: AppTheme.primary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.onSurfaceVariant),
            onPressed: () => ref.invalidate(usersProvider(_selectedRoleFilter)),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Section
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer.withValues(alpha: 0.05),
              border: Border(
                bottom: BorderSide(color: AppTheme.outlineVariant),
              ),
            ),
            child: Column(
              children: [
                // Role Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'admin', 'helpdesk', 'user'].map((role) {
                      final isSelected = _selectedRoleFilter == role;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppTheme.spacingSm),
                        child: FilterChip(
                          label: Text(role == 'All' ? 'Semua' : role.toUpperCase()),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedRoleFilter = role;
                            });
                          },
                          backgroundColor: AppTheme.surface,
                          selectedColor: AppTheme.primaryContainer,
                          checkmarkColor: AppTheme.onPrimary,
                          labelStyle: AppTheme.labelMedium.copyWith(
                            color: isSelected ? AppTheme.onPrimary : AppTheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primaryContainer : AppTheme.outlineVariant,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),

                // Search Field
                TextField(
                  controller: _searchController,
                  style: AppTheme.bodyLarge.copyWith(color: AppTheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan nama atau username...',
                    hintStyle: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.onSurfaceVariant),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppTheme.onSurfaceVariant),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      borderSide: const BorderSide(color: AppTheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      borderSide: const BorderSide(color: AppTheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                      vertical: 14,
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
              error: (err, stack) => Center(
                child: Text(
                  'Terjadi Kesalahan: $err',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.error),
                ),
              ),
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Text(
                          'Tidak ada pengguna ditemukan',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(usersProvider(_selectedRoleFilter));
                  },
                  color: AppTheme.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final currentRole = user['role'] ?? 'user';
                      final isCurrentAdmin = user['id'] == supabase.auth.currentUser?.id;

                      Color roleColor = currentRole == 'admin'
                          ? AppTheme.error
                          : (currentRole == 'helpdesk' ? AppTheme.secondary : AppTheme.primary);

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(color: AppTheme.outlineVariant),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: ExpansionTile(
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: Icon(Icons.person, color: roleColor, size: 22),
                          ),
                          title: Text(
                            user['full_name'] ?? 'Tanpa Nama',
                            style: AppTheme.titleSmall.copyWith(
                              color: AppTheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '@${user['username'] ?? 'username'}',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: isCurrentAdmin
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.spacingSm,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.tertiaryContainer,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                  ),
                                  child: Text(
                                    'Anda',
                                    style: AppTheme.labelSmall.copyWith(
                                      color: AppTheme.onTertiary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.more_vert,
                                  color: roleColor,
                                ),
                          children: [
                            // Detail User
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingMd,
                                vertical: AppTheme.spacingSm,
                              ),
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
                                  const SizedBox(height: AppTheme.spacingMd),

                                  // Role Change Buttons
                                  if (!isCurrentAdmin) ...[
                                    Text(
                                      'Ubah Role:',
                                      style: AppTheme.labelMedium.copyWith(
                                        color: AppTheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.spacingSm),
                                    Wrap(
                                      spacing: AppTheme.spacingSm,
                                      children: ['user', 'helpdesk', 'admin'].map((role) {
                                        final isCurrent = currentRole == role;
                                        return ElevatedButton(
                                          onPressed: isCurrent
                                              ? null
                                              : () => _changeUserRole(user['id'], role),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isCurrent
                                                ? AppTheme.surfaceContainerHigh
                                                : (role == 'admin'
                                                    ? AppTheme.error
                                                    : (role == 'helpdesk'
                                                        ? AppTheme.secondary
                                                        : AppTheme.primary)),
                                            foregroundColor: isCurrent
                                                ? AppTheme.onSurfaceVariant
                                                : AppTheme.onPrimary,
                                            elevation: AppTheme.elevationLevel1,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppTheme.spacingMd,
                                              vertical: AppTheme.spacingSm,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                            ),
                                          ),
                                          child: Text(
                                            role.toUpperCase(),
                                            style: AppTheme.labelSmall.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
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
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppTheme.onSurface,
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
            backgroundColor: AppTheme.tertiaryContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
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
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
          ),
        );
      }
    }
  }
}
