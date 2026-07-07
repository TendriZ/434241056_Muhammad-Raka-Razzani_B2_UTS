import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/ticket_provider.dart';

class TicketListPage extends ConsumerStatefulWidget {
  const TicketListPage({super.key});

  @override
  ConsumerState<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends ConsumerState<TicketListPage> {
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'normal':
        return Theme.of(context).colorScheme.secondaryContainer;
      case 'medium':
        return Theme.of(context).colorScheme.tertiaryContainer;
      case 'high':
        return Theme.of(context).colorScheme.errorContainer;
      case 'urgent':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }

  Color _getPriorityTextColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'normal':
        return Theme.of(context).colorScheme.onSecondaryContainer;
      case 'medium':
        return Theme.of(context).colorScheme.onTertiaryContainer;
      case 'high':
        return Theme.of(context).colorScheme.onErrorContainer;
      case 'urgent':
        return Theme.of(context).colorScheme.onError;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  String _safeSubstring(String text, int maxLength) {
    if (text.isEmpty) return text;
    return text.length > maxLength ? text.substring(0, maxLength) : text;
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + (text.length > 1 ? text.substring(1) : '');
  }

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(ticketsProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final role = profileAsync.value?['role'] ?? 'user';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: AppTheme.elevationLevel1,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onPressed: () {},
        ),
        title: Text(
          'IT Support',
          style: AppTheme.titleLarge.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        actions: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: AppTheme.spacingMd),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Section
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingMd,
            ),
            child: Column(
              children: [
                // Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daftar Tiket',
                      style: AppTheme.headlineMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role == 'user' ? 'Kelola dan pantau semua permintaan dukungan teknis Anda' : 'Kelola semua tiket masuk',
                      style: AppTheme.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMd),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari ID tiket, subjek, atau nama...',
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: 12,
                      ),
                      hintStyle: AppTheme.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['all', 'pending', 'on_progress', 'resolved'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      final label = filter == 'all'
                          ? 'Semua'
                          : filter == 'pending'
                              ? 'Pending'
                              : filter == 'on_progress'
                                  ? 'Diproses'
                                  : 'Selesai';
                      return Padding(
                        padding: const EdgeInsets.only(right: AppTheme.spacingSm),
                        child: FilterChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedFilter = filter);
                          },
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
                          selectedColor: Theme.of(context).colorScheme.primaryContainer,
                          labelStyle: AppTheme.labelLarge.copyWith(
                            color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurfaceVariant,
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
              ],
            ),
          ),

          // Ticket List
          Expanded(
            child: ticketsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text('Terjadi Kesalahan: $err'),
              ),
              data: (tickets) {
                // Filter tickets
                var filteredTickets = tickets.where((ticket) {
                  final status = ticket['status']?.toString() ?? '';
                  if (_selectedFilter != 'all') {
                    final filterStatus = _selectedFilter == 'on_progress' ? 'on_progress' : _selectedFilter;
                    if (status != filterStatus) return false;
                  }

                  // Search filter
                  if (_searchController.text.isNotEmpty) {
                    final query = _searchController.text.toLowerCase();
                    final title = (ticket['title'] ?? '').toLowerCase();
                    final description = (ticket['description'] ?? '').toLowerCase();
                    if (!title.contains(query) && !description.contains(query)) {
                      return false;
                    }
                  }

                  return true;
                }).toList();

                if (filteredTickets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Text(
                          role == 'user' ? 'Belum ada tiket yang dibuat' : 'Belum ada keluhan masuk',
                          style: AppTheme.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingMd,
                  ),
                  itemCount: filteredTickets.length,
                  itemBuilder: (context, index) {
                    final ticket = filteredTickets[index];
                    final status = ticket['status']?.toString() ?? 'pending';
                    final priority = ticket['priority']?.toString() ?? 'normal';
                    final priorityColor = _getPriorityColor(priority);
                    final priorityTextColor = _getPriorityTextColor(priority);

                    return GestureDetector(
                      onTap: () {
                        context.push('/ticket/detail/${ticket['id']}');
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.03),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ticket Header: ID, Priority Badge, Date
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '#${_safeSubstring(ticket['id']?.toString() ?? '', 8) ?? 'TK-000'}',
                                      style: AppTheme.labelMedium.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(width: AppTheme.spacingSm),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppTheme.spacingSm,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: priorityColor,
                                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (priority == 'urgent')
                                            Icon(Icons.error, size: 12, color: priorityTextColor)
                                          else if (priority == 'high')
                                            Icon(Icons.warning, size: 12, color: priorityTextColor)
                                          else if (priority == 'medium')
                                            Icon(Icons.info, size: 12, color: priorityTextColor)
                                          else
                                            Icon(Icons.info_outline, size: 12, color: priorityTextColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            _capitalizeFirst(priority),
                                            style: AppTheme.labelMedium.copyWith(
                                              color: priorityTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  _formatDate(ticket['created_at']),
                                  style: AppTheme.labelMedium.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacingSm),

                            // Ticket Title
                            Text(
                              ticket['title'] ?? 'Tanpa Judul',
                              style: AppTheme.titleMedium.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Ticket Description Preview
                            Text(
                              (ticket['description']?.toString().replaceAll('\n', ' ') ?? '...')
                                  .split('\n')
                                  .first
                                  .toString()
                                  .substring(
                                    0,
                                    (ticket['description']?.toString().length ?? 0).clamp(0, 100),
                                  ),
                              style: AppTheme.bodyMedium.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppTheme.spacingMd),

                            // Footer: Status Badge and Assignee
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.spacingSm,
                                    vertical: 4,
                                  ),
                                  decoration: AppTheme.getStatusBadgeStyle(status),
                                  child: Text(
                                    _formatStatus(status),
                                    style: AppTheme.labelSmall.copyWith(
                                      color: AppTheme.getStatusTextColor(status),
                                    ),
                                  ),
                                ),

                                // Assignee (if not user role)
                                if (role != 'user' && ticket['assigned_to'] != null)
                                  Row(
                                    children: [
Icon(Icons.person, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                      const SizedBox(width: 4),
                                      Text(
                                        (ticket['assigned_to_name'] ?? 'Assignee').toString().split(' ')[0],
                                        style: AppTheme.labelMedium.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: role == 'user'
          ? FloatingActionButton(
              onPressed: () {
                context.push('/ticket/create');
              },
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: AppTheme.elevationLevel2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              child: const Icon(Icons.add, size: 28),
            )
          : null,
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

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Baru saja';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} menit lalu';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} jam lalu';
      } else if (difference.inDays == 1) {
        return 'Kemarin';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari lalu';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return '';
    }
  }
}
