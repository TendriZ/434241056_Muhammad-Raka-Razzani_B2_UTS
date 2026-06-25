import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../ticket/presentation/providers/ticket_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(ticketStatsProvider);
    final ticketsAsync = ref.watch(ticketsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: AppTheme.elevationLevel1,
        automaticallyImplyLeading: false,
        title: Text(
          'Dashboard',
          style: AppTheme.titleLarge.copyWith(color: AppTheme.primary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.onSurfaceVariant),
            onPressed: () {
              context.push('/notification');
            },
            tooltip: 'Notifikasi',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Statistik Tiket',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Ringkasan tiket saat ini',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // Stats Grid
            statsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, _) => Center(
                child: Text(
                  'Error: $err',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.error),
                ),
              ),
              data: (stats) => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppTheme.spacingMd,
                mainAxisSpacing: AppTheme.spacingMd,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    'Total Tiket',
                    '${stats['total']}',
                    AppTheme.primary,
                    Icons.analytics_outlined,
                  ),
                  _buildStatCard(
                    'Open',
                    '${stats['pending']}',
                    AppTheme.secondaryContainer,
                    Icons.pending_outlined,
                  ),
                  _buildStatCard(
                    'Diproses',
                    '${stats['on_progress']}',
                    AppTheme.primaryContainer,
                    Icons.sync,
                  ),
                  _buildStatCard(
                    'Selesai',
                    '${stats['resolved']}',
                    AppTheme.tertiaryContainer,
                    Icons.check_circle_outline,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingXl),

            // Recent Activity Header
            Text(
              'Aktivitas Terbaru',
              style: AppTheme.titleLarge.copyWith(
                color: AppTheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),

            // Recent Tickets
            ticketsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, _) => Center(
                child: Text(
                  'Tidak dapat memuat aktivitas terbaru.',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.error),
                ),
              ),
              data: (tickets) {
                if (tickets.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingXl),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: AppTheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          Text(
                            'Belum ada tiket yang dibuat',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tickets.length > 3 ? 3 : tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
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
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMd,
                          vertical: AppTheme.spacingSm,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainer.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: Icon(
                            Icons.history,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          ticket['title'] ?? 'Tanpa Judul',
                          style: AppTheme.titleSmall.copyWith(
                            color: AppTheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Status: ${_formatStatus(ticket['status'] ?? 'Pending')}',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: Text(
                          _formatTime(ticket['created_at']),
                          style: AppTheme.labelSmall.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  count,
                  style: AppTheme.headlineLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.labelMedium.copyWith(
              color: AppTheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'on_progress':
        return 'Diproses';
      case 'resolved':
        return 'Selesai';
      default:
        return status;
    }
  }

  String _formatTime(dynamic date) {
    if (date == null) return '-';
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Baru saja';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m lalu';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}j lalu';
      } else {
        return '${dateTime.day}/${dateTime.month}';
      }
    } catch (e) {
      return '-';
    }
  }
}
