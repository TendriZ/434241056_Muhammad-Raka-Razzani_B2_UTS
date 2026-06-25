import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/notification_provider.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: AppTheme.elevationLevel1,
        title: Text(
          'Notifikasi',
          style: AppTheme.titleLarge.copyWith(color: AppTheme.primary),
        ),
        actions: [
          if (notificationState.notifications.isNotEmpty) ...[
            TextButton(
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
              ),
              child: Text(
                'Tandai Semua',
                style: AppTheme.labelLarge.copyWith(
                  color: AppTheme.primary,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.onSurfaceVariant),
              onPressed: () {
                _showClearDialog(context, ref);
              },
              tooltip: 'Hapus Semua',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Unread Count Banner
          if (notificationState.unreadCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              margin: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: AppTheme.primaryContainer.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: Text(
                      '${notificationState.unreadCount} notifikasi belum dibaca',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Notifications List
          Expanded(
            child: notificationState.notifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                      vertical: AppTheme.spacingSm,
                    ),
                    itemCount: notificationState.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notificationState.notifications[index];
                      return _buildNotificationCard(context, ref, notification);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: AppTheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'Belum Ada Notifikasi',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Notifikasi akan muncul di sini',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) {
    final isRead = notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: isRead ? AppTheme.surfaceContainerLow : AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isRead
              ? AppTheme.outlineVariant.withValues(alpha: 0.5)
              : AppTheme.primaryContainer.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: isRead
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: InkWell(
        onTap: () {
          ref.read(notificationProvider.notifier).markAsRead(notification.id);
          if (notification.ticketId != null) {
            context.push('/ticket/detail/${notification.ticketId}');
          }
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isRead
                      ? AppTheme.surfaceContainerHigh
                      : AppTheme.primaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(
                  _getNotificationIcon(notification.title),
                  color: isRead
                      ? AppTheme.onSurfaceVariant
                      : AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),

              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: AppTheme.titleSmall.copyWith(
                        color: AppTheme.onSurface,
                        fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      _formatTime(notification.createdAt),
                      style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Unread Indicator
              if (!isRead)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String title) {
    if (title.contains('Status')) {
      return Icons.update;
    } else if (title.contains('Baru')) {
      return Icons.add_circle_outline;
    } else if (title.contains('Dihapus')) {
      return Icons.delete_outline;
    } else if (title.contains('Ditugaskan')) {
      return Icons.person_add;
    } else {
      return Icons.notifications;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: const Text('Hapus Semua Notifikasi'),
        content: const Text('Apakah Anda yakin ingin menghapus semua notifikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.onSurfaceVariant,
            ),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(notificationProvider.notifier).clearAll();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.error,
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
