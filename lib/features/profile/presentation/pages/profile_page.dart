import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: AppTheme.elevationLevel1,
        automaticallyImplyLeading: false,
        title: Text(
          'Profil',
          style: AppTheme.titleLarge.copyWith(color: AppTheme.primary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.onSurfaceVariant),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                border: Border.all(color: AppTheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary,
                          AppTheme.primaryContainer,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // Name and Username
                  profileAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (err, _) => Text('Error: $err',
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.error),
                    ),
                    data: (profile) => Column(
                      children: [
                        Text(
                          profile?['full_name'] ?? 'User Baru',
                          style: AppTheme.headlineSmall.copyWith(
                            color: AppTheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile?['username'] != null
                              ? '@${profile!['username']}'
                              : '@username',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // Ticket Count Card
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(
                  color: AppTheme.primaryContainer.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: const Icon(
                          Icons.confirmation_number,
                          color: AppTheme.onPrimary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Text(
                        'Total Tiket Dibuat',
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                      vertical: AppTheme.spacingSm,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Text(
                      profileAsync.value?['ticket_count'] != null
                          ? '${profileAsync.value!['ticket_count']}'
                          : '0',
                      style: AppTheme.titleMedium.copyWith(
                        color: AppTheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // Settings Section
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingLg,
                      vertical: AppTheme.spacingSm,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppTheme.surfaceContainerHigh
                            : AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Icon(
                        isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: AppTheme.primary,
                      ),
                    ),
                    title: Text(
                      'Dark Mode',
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.onSurface,
                      ),
                    ),
                    trailing: Switch(
                      value: isDarkMode,
                      activeColor: AppTheme.primary,
                      onChanged: (val) {
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: AppTheme.outlineVariant,
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingLg,
                      vertical: AppTheme.spacingSm,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.tertiaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Icon(
                        Icons.help_outline,
                        color: AppTheme.tertiary,
                      ),
                    ),
                    title: Text(
                      'Bantuan & Dukungan',
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.onSurface,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppTheme.onSurfaceVariant,
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          ),
                          title: const Text('Bantuan & Dukungan'),
                          content: const Text(
                            'Untuk bantuan, hubungi tim IT Support melalui fitur tiket.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primary,
                              ),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Divider(
                    height: 1,
                    color: AppTheme.outlineVariant,
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingLg,
                      vertical: AppTheme.spacingSm,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: AppTheme.secondary,
                      ),
                    ),
                    title: Text(
                      'Tentang Aplikasi',
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.onSurface,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppTheme.onSurfaceVariant,
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          ),
                          title: const Text('Tentang Aplikasi'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'E-Ticketing Helpdesk',
                                style: AppTheme.titleMedium.copyWith(
                                  color: AppTheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Versi 1.0.0',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Sistem manajemen tiket untuk layanan IT Support.',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primary,
                              ),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  side: const BorderSide(color: AppTheme.error),
                ),
                icon: const Icon(Icons.logout),
                label: Text(
                  'Keluar Akun',
                  style: AppTheme.labelLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
