import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/ticket_provider.dart';

// Helper function for safe substring
String _safeUserIdSubstring(String? userId) {
  if (userId == null || userId.isEmpty) return 'Unknown';
  return userId.length > 8 ? userId.substring(0, 8) : userId;
}

class TicketDetailPage extends ConsumerStatefulWidget {
  final String ticketId;

  const TicketDetailPage({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends ConsumerState<TicketDetailPage> {
  bool _isUpdatingStatus = false;
  bool _isAssigning = false;
  bool _isPostingComment = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Add comment function (FR-007/BR-002)
  Future<void> _addComment(String ticketId) async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan tulis komentar terlebih dahulu')),
        );
      }
      return;
    }

    setState(() => _isPostingComment = true);

    try {
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser!.id;

      // Insert comment ke ticket_history
      await supabase.from('ticket_history').insert({
        'ticket_id': ticketId,
        'user_id': userId,
        'action': 'Komentar',
        'message': comment,
      });

      // Clear input
      _commentController.clear();

      // Invalidate providers to refresh UI
      ref.invalidate(ticketHistoryProvider(ticketId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Komentar berhasil ditambahkan'),
            backgroundColor: AppTheme.tertiaryContainer,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan komentar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPostingComment = false);
    }
  }

  // Delete ticket function (FR-007/BR-002) - Admin only
  Future<void> _deleteTicket(String ticketId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Hapus Tiket',
          style: AppTheme.titleMedium.copyWith(color: AppTheme.onSurface),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus tiket ini? Tindakan ini tidak dapat dibatalkan.',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: AppTheme.labelLarge.copyWith(color: AppTheme.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: AppTheme.onError,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isUpdatingStatus = true);

    try {
      final supabase = ref.read(supabaseClientProvider);

      // Delete ticket (cascade will delete history & attachments)
      await supabase.from('tickets').delete().eq('id', ticketId);

      // Invalidate providers
      ref.invalidate(ticketDetailProvider(ticketId));
      ref.invalidate(ticketHistoryProvider(ticketId));
      ref.invalidate(ticketStatsProvider);
      ref.invalidate(ticketsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tiket berhasil dihapus'),
            backgroundColor: AppTheme.tertiaryContainer,
          ),
        );
        Navigator.pop(context); // Go back to ticket list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus tiket: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  // Assign ticket to helpdesk function (FR-007)
  // Ketika admin assign ke helpdesk, status otomatis berubah menjadi "on_progress"
  Future<void> _assignTicket(String ticketId, String? helpdeskId, String? helpdeskName) async {
    if (helpdeskId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih helpdesk terlebih dahulu')),
        );
      }
      return;
    }

    setState(() => _isAssigning = true);

    try {
      final supabase = ref.read(supabaseClientProvider);
      final ticket = ref.read(ticketDetailProvider(ticketId)).value;
      final oldAssignee = ticket?['assigned_to_name']?.toString() ?? 'Belum ada';
      final oldStatus = ticket?['status']?.toString() ?? 'pending';
      final userId = supabase.auth.currentUser!.id;

      // Update ticket dengan assigned_to DAN status otomatis berubah ke on_progress
      await supabase
          .from('tickets')
          .update({
            'assigned_to': helpdeskId,
            'status': 'on_progress', // Otomatis ubah status ke on_progress saat assign
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', ticketId);

      // Insert history record untuk assign
      await supabase.from('ticket_history').insert({
        'ticket_id': ticketId,
        'user_id': userId,
        'action': 'Assigned',
        'message': 'Tiket ditugaskan dari $oldAssignee kepada $helpdeskName',
      });

      // Insert history record untuk status change
      await supabase.from('ticket_history').insert({
        'ticket_id': ticketId,
        'user_id': userId,
        'action': 'Update Status',
        'message': 'Status otomatis diubah dari $oldStatus menjadi on_progress (karena ditugaskan)',
        'status': 'on_progress',
      });

      // Invalidate providers to refresh UI
      ref.invalidate(ticketDetailProvider(ticketId));
      ref.invalidate(ticketHistoryProvider(ticketId));
      ref.invalidate(ticketStatsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tiket ditugaskan ke $helpdeskName & status menjadi Diproses'),
            backgroundColor: AppTheme.tertiaryContainer,
          ),
        );
        Navigator.pop(context); // Close bottom sheet
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menugaskan tiket: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAssigning = false);
    }
  }

  // Finish ticket function untuk Helpdesk (FR-006)
  // Ketika helpdesk selesai mengerjakan, status berubah menjadi "resolved"
  Future<void> _finishTicket(String ticketId) async {
    setState(() => _isUpdatingStatus = true);

    try {
      final supabase = ref.read(supabaseClientProvider);
      final ticket = ref.read(ticketDetailProvider(ticketId)).value;
      final oldStatus = ticket?['status']?.toString() ?? 'on_progress';
      final userId = supabase.auth.currentUser!.id;

      // Update ticket status ke resolved
      await supabase
          .from('tickets')
          .update({'status': 'resolved', 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', ticketId);

      // Insert history record
      await supabase.from('ticket_history').insert({
        'ticket_id': ticketId,
        'user_id': userId,
        'action': 'Update Status',
        'message': 'Tiket selesai dikerjakan oleh helpdesk',
        'status': 'resolved',
      });

      // Invalidate providers to refresh UI
      ref.invalidate(ticketDetailProvider(ticketId));
      ref.invalidate(ticketHistoryProvider(ticketId));
      ref.invalidate(ticketStatsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tiket selesai! Status berubah menjadi Selesai'),
            backgroundColor: AppTheme.tertiaryContainer,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyelesaikan tiket: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  // Show assign bottom sheet (for admin only - FR-007)
  void _showAssignBottomSheet(BuildContext context, String ticketId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String? selectedHelpdeskId;
        String? selectedHelpdeskName;

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: AppTheme.spacingSm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.all(AppTheme.spacingLg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tugaskan ke Helpdesk',
                      style: AppTheme.titleLarge.copyWith(color: AppTheme.onSurface),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Helpdesk list
              Consumer(
                builder: (context, ref, child) {
                  final helpdeskAsync = ref.watch(helpdeskUsersProvider);
                  return helpdeskAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(AppTheme.spacingXl),
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => Padding(
                      padding: EdgeInsets.all(AppTheme.spacingLg),
                      child: Text('Gagal memuat helpdesk: $e'),
                    ),
                    data: (helpdesks) {
                      if (helpdesks.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.all(AppTheme.spacingLg),
                          child: Text(
                            'Tidak ada helpdesk tersedia',
                            style: AppTheme.bodyMedium.copyWith(color: AppTheme.onSurfaceVariant),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: helpdesks.length,
                        separatorBuilder: (context, index) => Divider(
                          color: AppTheme.outlineVariant,
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final helpdesk = helpdesks[index];
                          final id = helpdesk['id']?.toString() ?? '';
                          final name = helpdesk['name']?.toString() ?? 'No Name';
                          final username = helpdesk['username']?.toString() ?? '';

                          return RadioListTile<String>(
                            title: Text(
                              name,
                              style: AppTheme.bodyLarge.copyWith(color: AppTheme.onSurface),
                            ),
                            subtitle: Text(
                              '@$username',
                              style: AppTheme.bodyMedium.copyWith(color: AppTheme.onSurfaceVariant),
                            ),
                            value: id,
                            groupValue: selectedHelpdeskId,
                            onChanged: (value) {
                              selectedHelpdeskId = value;
                              selectedHelpdeskName = name;
                            },
                            activeColor: AppTheme.primary,
                          );
                        },
                      );
                    },
                  );
                },
              ),
              // Assign button
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppTheme.spacingLg),
                child: ElevatedButton(
                  onPressed: _isAssigning
                      ? null
                      : () => _assignTicket(ticketId, selectedHelpdeskId, selectedHelpdeskName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: _isAssigning
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Tugaskan', style: AppTheme.labelLarge),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticketAsync = ref.watch(ticketDetailProvider(widget.ticketId));
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
          '#INC-2023-${widget.ticketId.length > 6 ? widget.ticketId.substring(0, 6) : widget.ticketId}',
          style: AppTheme.titleMedium.copyWith(color: AppTheme.primary),
        ),
        actions: [
          ticketAsync.whenOrNull(
            data: (ticket) {
              if (ticket != null) {
                final status = ticket['status']?.toString() ?? 'pending';
                final role = profileAsync.value?['role'] ?? 'user';

                // Status badge untuk semua user
                final statusBadge = Container(
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

                // Menu button untuk Admin (FR-007)
                if (role == 'admin') {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      statusBadge,
                      const SizedBox(width: 8),
                      // Menu with delete option
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: AppTheme.onSurfaceVariant),
                        onSelected: (value) {
                          if (value == 'delete') {
                            _deleteTicket(widget.ticketId);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: AppTheme.error, size: 20),
                                SizedBox(width: 12),
                                Text(
                                  'Hapus Tiket',
                                  style: TextStyle(color: AppTheme.error),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                // Tombol Finish untuk Helpdesk jika status on_progress (FR-006)
                if (role == 'helpdesk' && status == 'on_progress') {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      statusBadge,
                      const SizedBox(width: 8),
                      // Finish button
                      ElevatedButton.icon(
                        onPressed: _isUpdatingStatus
                            ? null
                            : () => _finishTicket(widget.ticketId),
                        icon: _isUpdatingStatus
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle, size: 18),
                        label: const Text('Selesai'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.tertiary,
                          foregroundColor: AppTheme.onTertiary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingMd,
                            vertical: AppTheme.spacingSm,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return statusBadge;
              }
              return const SizedBox();
            },
          ) ?? const SizedBox(),
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
                                  'Pelapor: ${_safeUserIdSubstring(ticket['user_id']?.toString())}...',
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
                                // Assign button for admin (FR-007)
                                if (role == 'admin')
                                  IconButton(
                                    icon: const Icon(Icons.person_add, color: AppTheme.primary),
                                    onPressed: () => _showAssignBottomSheet(context, widget.ticketId),
                                    tooltip: 'Tugaskan ke Helpdesk',
                                  )
                                else
                                  const SizedBox(width: 48),
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
                          _TicketTimelineWidget(ticketId: widget.ticketId),
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
                        controller: _commentController,
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
                        onSubmitted: (_) => _addComment(widget.ticketId),
                        enabled: !_isPostingComment,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    IconButton(
                      icon: _isPostingComment
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                      color: AppTheme.primary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.onPrimary,
                        padding: const EdgeInsets.all(AppTheme.spacingSm),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      onPressed: _isPostingComment
                          ? null
                          : () => _addComment(widget.ticketId),
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
                _safeUserIdSubstring(log['user_id']?.toString()) ?? 'User',
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
