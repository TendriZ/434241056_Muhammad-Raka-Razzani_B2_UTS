import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/admin_provider.dart';

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
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: AppTheme.elevationLevel1,
        automaticallyImplyLeading: false,
        title: Text(
          'Manajemen Pengguna',
          style: AppTheme.titleLarge.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.onSurfaceVariant),
            onPressed: () => ref.invalidate(usersProvider(_selectedRoleFilter)),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateUserDialog(),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          // Filter & Search Section
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
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
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          selectedColor: Theme.of(context).colorScheme.primaryContainer,
                          checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                          labelStyle: AppTheme.labelMedium.copyWith(
                            color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          side: BorderSide(
                            color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.outlineVariant,
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
                  style: AppTheme.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan nama atau username...',
                    hintStyle: AppTheme.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
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
                  style: AppTheme.bodyMedium.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ),
              data: (users) {
                // Filter by search query
                final filteredUsers = _searchQuery.isEmpty
                    ? users
                    : users.where((user) {
                        final name = (user['name'] ?? '').toLowerCase();
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
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Text(
                          'Tidak ada pengguna ditemukan',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  color: Theme.of(context).colorScheme.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final currentRole = user['role'] ?? 'user';
                      final isCurrentAdmin = user['id'] == supabase.auth.currentUser?.id;

                      Color roleColor = currentRole == 'admin'
                          ? Theme.of(context).colorScheme.error
                          : (currentRole == 'helpdesk' ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.primary);

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow.withOpacity(0.03),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: ExpansionTile(
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: roleColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: Icon(Icons.person, color: roleColor, size: 22),
                          ),
                          title: Text(
                            user['name'] ?? 'Tanpa Nama',
                            style: AppTheme.titleSmall.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '@${user['username'] ?? 'username'}',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: isCurrentAdmin
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.spacingSm,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.tertiaryContainer,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                  ),
                                  child: Text(
                                    'Anda',
                                    style: AppTheme.labelSmall.copyWith(
                                      color: Theme.of(context).colorScheme.onTertiary,
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
                                        color: Theme.of(context).colorScheme.onSurface,
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
                                                ? Theme.of(context).colorScheme.surfaceContainerHigh
                                                : (role == 'admin'
                                                    ? Theme.of(context).colorScheme.error
                                                    : (role == 'helpdesk'
                                                        ? Theme.of(context).colorScheme.secondary
                                                        : Theme.of(context).colorScheme.primary)),
                                            foregroundColor: isCurrent
                                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                                : Theme.of(context).colorScheme.onPrimary,
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
                                    const SizedBox(height: AppTheme.spacingMd),
                                    // Delete User Button
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () => _confirmDeleteUser(user['id'], user['name'] ?? 'Pengguna'),
                                        icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error, size: 20),
                                        label: Text(
                                          'Hapus Pengguna',
                                          style: AppTheme.labelMedium.copyWith(
                                            color: Theme.of(context).colorScheme.error,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Theme.of(context).colorScheme.error),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
                                        ),
                                      ),
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
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor ?? Theme.of(context).colorScheme.onSurface,
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

      final adminService = ref.read(adminProvider);
      await adminService.changeUserRole(userId, newRole);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Role berhasil diubah menjadi $newRole'),
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah role: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
          ),
        );
      }
    }
  }

  Future<void> _showCreateUserDialog() async {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'user';
    bool isLoading = false;
    bool obscurePassword = true;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              title: Row(
                children: [
                  Icon(Icons.person_add, color: Theme.of(context).colorScheme.primary, size: 24),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    'Tambah Pengguna',
                    style: AppTheme.titleMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: AppTheme.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: const Icon(Icons.person, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    TextField(
                      controller: usernameController,
                      style: AppTheme.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: const Icon(Icons.alternate_email, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      style: AppTheme.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility_off : Icons.visibility,
                            size: 20,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      style: AppTheme.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Role',
                        prefixIcon: const Icon(Icons.badge, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'user', child: Text('USER')),
                        DropdownMenuItem(value: 'helpdesk', child: Text('HELPDESK')),
                        DropdownMenuItem(value: 'admin', child: Text('ADMIN')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedRole = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(ctx),
                  child: Text(
                    'Batal',
                    style: AppTheme.labelLarge.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final username = usernameController.text.trim();
                          final password = passwordController.text.trim();

                          if (name.isEmpty || username.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: const Text('Semua field harus diisi'),
                                backgroundColor: Theme.of(context).colorScheme.error,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                ),
                              ),
                            );
                            return;
                          }
                          if (password.length < 6) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: const Text('Password minimal 6 karakter'),
                                backgroundColor: Theme.of(context).colorScheme.error,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isLoading = true;
                          });

                          try {
                            final adminService = ref.read(adminProvider);
                            await adminService.createUser(
                              name: name,
                              username: username,
                              password: password,
                              role: selectedRole,
                            );

                            if (ctx.mounted) Navigator.pop(ctx);
                            if (this.context.mounted) {
                              ref.invalidate(usersProvider(_selectedRoleFilter));
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text('Pengguna $name berhasil ditambahkan'),
                                  backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() {
                              isLoading = false;
                            });
                            if (this.context.mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal: $e'),
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary),
                        )
                      : Text('Simpan', style: AppTheme.labelLarge),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteUser(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_rounded, color: Theme.of(context).colorScheme.error, size: 24),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                'Hapus Pengguna',
                style: AppTheme.titleMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
          content: Text(
            'Yakin ingin menghapus "$userName"? Tindakan ini tidak dapat dibatalkan.',
            style: AppTheme.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Batal',
                style: AppTheme.labelLarge.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: Text('Hapus', style: AppTheme.labelLarge),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteUser(userId);
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final adminService = ref.read(adminProvider);
      await adminService.deleteUser(userId);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pengguna berhasil dihapus'),
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
