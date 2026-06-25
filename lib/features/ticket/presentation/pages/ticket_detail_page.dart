import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: AppTheme.elevationLevel1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceVariant),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '#INC-2023-${ticketId.substring(0, 6)}',
          style: AppTheme.titleMedium.copyWith(color: AppTheme.primary),
        ),
        actions: [
          ticketAsync.whenOrNull(
            data: (ticket) {
              if (ticket != null) {
                final status = ticket['status']?.toString() ?? 'pending';
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm,
                    vertical: 4,
                  ),
                  decoration: AppTheme.getStatusBadgeStyle(status),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        size: 14,
                        color: AppTheme.getStatusTextColor(status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatStatus(status),
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.getStatusTextColor(status),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ) ?? const SizedBox(),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: ticketAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (ticket) {
          if (ticket == null) {
            return Center(
              child: Text(
                'Tiket tidak ditemukan',
                style: AppTheme.bodyLarge.copyWith(color: AppTheme.onSurfaceVariant),
              ),
            );
          }

          final role = profileAsync.value?['role'] ?? 'user';
          final priority = ticket['priority']?.toString() ?? 'normal';
          final category = ticket['category']?.toString() ?? '-';

          return Column(
            children: [
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Info Card
                      Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingLg),
                        padding: const EdgeInsets.all(AppTheme.spacingLg),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(color: AppTheme.surfaceContainerHigh),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              ticket['title'] ?? 'Tanpa Judul',
                              style: AppTheme.titleLarge.copyWith(
                                color: AppTheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingSm),

                            // Meta Info
                            Wrap(
                              spacing: AppTheme.spacingLg,
                              runSpacing: AppTheme.spacingMd,
                              children: [
                                // Date
                                _buildMetaInfo(
                                  Icons.calendar_today,
                                  _formatDateTime(ticket['created_at']),
                                ),
                                // Reporter
                                _buildMetaInfo(
                                  Icons.person,
                                  'Pelapor: ${ticket['user_id']?.toString().substring(0, 8)}...',
                                ),
                              ],
                            ),

                            const SizedBox(height: AppTheme.spacingMd),

                            // Grid Info
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoCard('Prioritas', _formatPriority(priority)),
                                ),
                                const SizedBox(width: AppTheme.spacingMd),
                                Expanded(
                                  child: _buildInfoCard('Kategori', category),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacingMd),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoCard(
                                    'Ditugaskan Kepada',
                                    ticket['assigned_to_name'] ?? 'Belum ada',
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacingMd),
                                Expanded(
                                  child: _buildInfoCard(
                                    'Estimasi Selesai',
                                    _formatDate(ticket['updated_at']),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Description Section
                      Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingLg),
                        padding: const EdgeInsets.all(AppTheme.spacingLg),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(color: AppTheme.surfaceContainerHigh),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.description,
                                  color: AppTheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                const SizedBox(width: AppTheme.spacingSm),
                                Text(
                                  'Deskripsi Kendala',
                                  style: AppTheme.titleMedium.copyWith(
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacingSm),
                            Text(
                              ticket['description'] ?? 'Tidak ada deskripsi',
                              style: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Attachments Section
                      if (ticket['image_url'] != null &&
                          ticket['image_url'].toString().isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: AppTheme.spacingLg),
                          padding: const EdgeInsets.all(AppTheme.spacingLg),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            border: Border.all(color: AppTheme.surfaceContainerHigh),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.attachment,
                                    color: AppTheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppTheme.spacingSm),
                                  Text(
                                    'Lampiran',
                                    style: AppTheme.titleMedium.copyWith(
                                      color: AppTheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacingSm),
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 1,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: 100,
                                      margin: const EdgeInsets.only(right: AppTheme.spacingSm),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                        border: Border.all(color: AppTheme.outlineVariant),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                        child: Image.network(
                                          ticket['image_url'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: AppTheme.surfaceContainerLow,
                                              child: const Center(
                                                child: Icon(Icons.broken_image),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Activity & Comments Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aktivitas & Komentar',
                            style: AppTheme.titleMedium.copyWith(
                              color: AppTheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          _TicketTimelineWidget(ticketId: ticketId),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Sticky Input
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(
                    top: BorderSide(color: AppTheme.outlineVariant),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      color: AppTheme.onSurfaceVariant,
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tambah komentar...',
                          filled: true,
                          fillColor: AppTheme.surfaceContainerLowest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            borderSide: const BorderSide(color: AppTheme.outline),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingMd,
                            vertical: 12,
                          ),
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: AppTheme.primary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.onPrimary,
                        padding: const EdgeInsets.all(AppTheme.spacingSm),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetaInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppTheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelMedium.copyWith(color: AppTheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.onSurface),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'on_progress':
        return Icons.sync;
      case 'resolved':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
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

  String _formatPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'normal':
        return 'Normal';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'Tinggi';
      case 'urgent':
        return 'Urgent';
      default:
        return priority;
    }
  }

  String _formatDateTime(dynamic date) {
    if (date == null) return '-';
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      return '${dateTime.day} ${_getMonth(dateTime.month)} ${dateTime.year}, ${_formatTime(dateTime.hour)}:${_formatTime(dateTime.minute)}';
    } catch (e) {
      return '-';
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      return '${dateTime.day} ${_getMonth(dateTime.month)} ${dateTime.year}';
    } catch (e) {
      return '-';
    }
  }

  String _getMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }

  String _formatTime(int hour) {
    return hour.toString().padLeft(2, '0');
  }
}

class _TicketTimelineWidget extends ConsumerWidget {
  final String ticketId;

  const _TicketTimelineWidget({required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(ticketHistoryProvider(ticketId));

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Gagal memuat history: $e',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.error),
        ),
      ),
      data: (records) {
        if (records.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Text(
                'Belum ada aktivitas',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.onSurfaceVariant),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(left: AppTheme.spacingLg, bottom: AppTheme.spacingLg),
          child: Column(
            children: [
              // Timeline
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: records.map<Widget>((log) {
                  final isSystemUpdate = log['action'] == 'Update Status' || log['action'] == 'Assigned';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline Item
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timeline Dot
                            Container(
                              margin: const EdgeInsets.only(left: 2),
                              width: isSystemUpdate ? 20 : 24,
                              height: isSystemUpdate ? 20 : 24,
                              decoration: BoxDecoration(
                                color: isSystemUpdate
                                    ? AppTheme.secondaryContainer
                                    : (log['action'] == 'Komentar' ? AppTheme.surfaceVariant : AppTheme.primary),
                                border: Border.all(
                                  color: AppTheme.background,
                                  width: 4,
                                ),
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: Center(
                                child: Icon(
                                  _getTimelineIcon(log['action']),
                                  size: isSystemUpdate ? 12 : 14,
                                  color: isSystemUpdate
                                      ? AppTheme.onSecondaryContainer
                                      : (log['action'] == 'Komentar' ? AppTheme.onSurface : AppTheme.onPrimary),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingMd),
                            // Content
                            Expanded(
                              child: isSystemUpdate
                                  ? _buildSystemUpdateItem(log)
                                  : _buildCommentItem(log),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> log) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                log['user_id']?.toString().substring(0, 8) ?? 'User',
                style: AppTheme.labelLarge.copyWith(
                  color: AppTheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatDateTime(log['created_at']),
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            log['message'] ?? '',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemUpdateItem(Map<String, dynamic> log) {
    final action = log['action'] ?? '';
    final message = log['message'] ?? '';

    // Parse status change from message
    String? fromStatus, toStatus;
    if (action == 'Update Status' && message.contains('dari') && message.contains('menjadi')) {
      final parts = message.split('dari ');
      if (parts.length > 1) {
        final toParts = parts[1].split(' menjadi ');
        fromStatus = toParts[0];
        toStatus = toParts.length > 1 ? toParts[1].split('.')[0] : toParts[1];
      }
    }

    return Row(
      children: [
        Text(
          'Sistem',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          ' mengubah status dari ',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.onSurfaceVariant),
        ),
        if (fromStatus != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              _formatStatus(fromStatus),
              style: AppTheme.bodySmall.copyWith(color: AppTheme.onSurface),
            ),
          ),
        Text(' menjadi '),
        if (toStatus != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              _formatStatus(toStatus),
              style: AppTheme.bodySmall.copyWith(color: AppTheme.onSecondaryContainer),
            ),
          ),
        Text(' '),
        Text(
          _formatDateTime(log['created_at']),
          style: AppTheme.labelSmall.copyWith(
            color: AppTheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  IconData _getTimelineIcon(String? action) {
    switch (action?.toLowerCase()) {
      case 'update status':
      case 'assigned':
        return Icons.sync;
      case 'komentar':
        return Icons.person;
      default:
        return Icons.check_circle;
    }
  }

  String _formatDateTime(dynamic date) {
    if (date == null) return '-';
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      return '${dateTime.day} ${_getMonth(dateTime.month)} ${dateTime.year}, ${_formatTime(dateTime.hour)}:${_formatTime(dateTime.minute)}';
    } catch (e) {
      return '-';
    }
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

  String _getMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }

  String _formatTime(int hour) {
    return hour.toString().padLeft(2, '0');
  }
}
