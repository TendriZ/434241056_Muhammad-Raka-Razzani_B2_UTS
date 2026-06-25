import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/ticket_provider.dart';

class CreateTicketPage extends ConsumerStatefulWidget {
  const CreateTicketPage({super.key});

  @override
  ConsumerState<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends ConsumerState<CreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;
  String? _selectedCategory = 'technical';
  String _selectedPriority = 'normal';

  final List<({String name, List<int> bytes})> _attachments = [];
  final ImagePicker _imagePicker = ImagePicker();

  // Categories from Stitch design
  final List<Map<String, dynamic>> _categories = [
    {'value': 'technical', 'label': 'Technical'},
    {'value': 'hardware', 'label': 'Hardware'},
    {'value': 'software', 'label': 'Software'},
    {'value': 'network', 'label': 'Network'},
    {'value': 'other', 'label': 'Other'},
  ];

  // Priorities from Stitch design
  final List<Map<String, dynamic>> _priorities = [
    {'value': 'normal', 'label': 'Normal'},
    {'value': 'medium', 'label': 'Medium'},
    {'value': 'high', 'label': 'High'},
    {'value': 'urgent', 'label': 'Urgent'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        final sizeInMB = bytes.length / (1024 * 1024);

        if (sizeInMB > 10) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Foto terlalu besar. Maksimal 10MB')),
            );
          }
          return;
        }

        setState(() {
          _attachments.add((name: photo.name, bytes: bytes));
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto berhasil diambil!'),
              backgroundColor: AppTheme.tertiaryContainer,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka kamera: $e')),
        );
      }
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx'],
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        int addedCount = 0;
        for (var file in result.files) {
          final sizeInMB = file.size / (1024 * 1024);

          if (sizeInMB > 10) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('File "${file.name}" terlalu besar. Maksimal 10MB'),
                ),
              );
            }
            continue;
          }

          final bytes = file.bytes ?? await file.xFile.readAsBytes();
          setState(() {
            _attachments.add((name: file.name, bytes: bytes));
          });
          addedCount++;
        }

        if (addedCount > 0 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$addedCount file berhasil dipilih'),
              backgroundColor: AppTheme.tertiaryContainer,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih file: $e')),
        );
      }
    }
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser!.id;

      final ticketResponse = await supabase.from('tickets').insert({
        'user_id': userId,
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'status': 'pending',
        'category': _selectedCategory,
        'priority': _selectedPriority,
      }).select().single();

      final ticketId = ticketResponse['id'].toString();

      if (_attachments.isNotEmpty) {
        try {
          final attachment = _attachments.first;
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final filePath = 'tickets/$ticketId/$timestamp-${attachment.name}';

          await supabase.storage
              .from('ticket-attachments')
              .uploadBinary(filePath, attachment.bytes as dynamic);

          final imageUrl = supabase.storage.from('ticket-attachments').getPublicUrl(filePath);

          await supabase.from('tickets').update({
            'image_url': imageUrl,
          }).eq('id', ticketId);

        } catch (uploadError) {
          debugPrint('Upload attachment gagal: $uploadError');
        }
      }

      ref.invalidate(ticketsProvider);
      ref.invalidate(ticketStatsProvider);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tiket berhasil dibuat!'),
          backgroundColor: AppTheme.tertiaryContainer,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat tiket: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: AppTheme.elevationLevel1,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.onSurfaceVariant),
          onPressed: () {},
        ),
        title: Text(
          'IT Support',
          style: AppTheme.titleLarge.copyWith(color: AppTheme.primary),
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
            child: const Icon(Icons.person, size: 16, color: AppTheme.onSurfaceVariant),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingLg,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Text(
                'Buat Tiket Baru',
                style: AppTheme.headlineSmall.copyWith(color: AppTheme.onSurface),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                'Silakan isi detail masalah yang Anda alami.',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Form Card
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.surfaceVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Input
                    Text(
                      'Judul Tiket',
                      style: AppTheme.labelLarge.copyWith(color: AppTheme.onSurface),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Misal: Komputer tidak bisa menyala',
                        filled: true,
                        fillColor: AppTheme.surfaceContainerLowest,
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
                          vertical: 12,
                        ),
                      ),
                      style: AppTheme.bodyLarge.copyWith(color: AppTheme.onSurface),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Judul tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Description Input
                    Text(
                      'Deskripsi Masalah',
                      style: AppTheme.labelLarge.copyWith(color: AppTheme.onSurface),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    TextFormField(
                      controller: _descController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Jelaskan secara detail masalah yang terjadi...',
                        filled: true,
                        fillColor: AppTheme.surfaceContainerLowest,
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
                          vertical: 12,
                        ),
                      ),
                      style: AppTheme.bodyLarge.copyWith(color: AppTheme.onSurface),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Sertakan deskripsi masalah';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Category Dropdown
                    Text(
                      'Kategori',
                      style: AppTheme.labelLarge.copyWith(color: AppTheme.onSurface),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceContainerLowest,
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
                          vertical: 12,
                        ),
                      ),
                      items: _categories.map<DropdownMenuItem<String>>((category) {
                        return DropdownMenuItem<String>(
                          value: category['value'] as String,
                          child: Text(category['label']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Priority Chips
                    Text(
                      'Prioritas',
                      style: AppTheme.labelLarge.copyWith(color: AppTheme.onSurface),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Wrap(
                      spacing: AppTheme.spacingSm,
                      children: _priorities.map((priority) {
                        final isSelected = _selectedPriority == priority['value'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedPriority = priority['value']),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingMd,
                              vertical: AppTheme.spacingSm,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.getPriorityBadgeColor(priority['value'])
                                  : AppTheme.surface,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.getPriorityBorderColor(priority['value'])
                                    : AppTheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (priority['value'] == 'urgent')
                                  const Icon(Icons.error, size: 14, color: AppTheme.onError)
                                else if (priority['value'] == 'high')
                                  const Icon(Icons.warning, size: 14, color: AppTheme.priorityOnHigh)
                                else if (priority['value'] == 'medium')
                                  const Icon(Icons.info, size: 14, color: AppTheme.priorityOnMedium)
                                else
                                  Icon(Icons.info_outline, size: 14, color: AppTheme.priorityOnNormal),
                                const SizedBox(width: 4),
                                Text(
                                  priority['label'],
                                  style: AppTheme.labelMedium.copyWith(
                                    color: isSelected
                                        ? AppTheme.getPriorityTextColor(priority['value'])
                                        : AppTheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // File Upload Section
              Text(
                'Lampiran (Opsional)',
                style: AppTheme.labelLarge.copyWith(color: AppTheme.onSurface),
              ),
              const SizedBox(height: AppTheme.spacingSm),

              // Upload Area or File List
              _attachments.isEmpty
                  ? GestureDetector(
                      onTap: _pickFiles,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMd,
                          vertical: AppTheme.spacingLg,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLowest,
                          border: Border.all(
                            color: AppTheme.outlineVariant,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 48,
                              color: AppTheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: AppTheme.spacingSm),
                            Text(
                              'Klik untuk unggah file atau seret ke sini',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Maksimal 10MB (JPG, PNG, PDF)',
                              style: AppTheme.labelMedium.copyWith(
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            border: Border.all(color: AppTheme.outlineVariant),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _attachments.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final file = _attachments[index];
                              return ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                  ),
                                  child: Icon(
                                    _getFileIcon(file.name),
                                    size: 20,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                title: Text(
                                  file.name,
                                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.onSurface),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${(file.bytes.length / 1024).toStringAsFixed(1)} KB',
                                  style: AppTheme.labelMedium.copyWith(color: AppTheme.onSurfaceVariant),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close),
                                  color: AppTheme.error,
                                  onPressed: () => _removeAttachment(index),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickFiles,
                                icon: const Icon(Icons.add_photo_alternate),
                                label: const Text('Tambah File'),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingMd),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _openCamera,
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Kamera'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
              const SizedBox(height: AppTheme.spacingLg),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryContainer,
                    foregroundColor: AppTheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingLg,
                      vertical: AppTheme.spacingMd,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    elevation: AppTheme.elevationLevel2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppTheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.send, size: 20),
                            SizedBox(width: AppTheme.spacingSm),
                            Text('KIRIM TIKET'),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color getPriorityBadgeColor(String priority) {
    switch (priority) {
      case 'normal':
        return AppTheme.secondaryContainer;
      case 'medium':
        return AppTheme.priorityMedium;
      case 'high':
        return AppTheme.errorContainer;
      case 'urgent':
        return AppTheme.error;
      default:
        return AppTheme.surface;
    }
  }

  Color getPriorityBorderColor(String priority) {
    switch (priority) {
      case 'normal':
        return AppTheme.secondaryContainer;
      case 'medium':
        return AppTheme.priorityMedium;
      case 'high':
        return AppTheme.errorContainer;
      case 'urgent':
        return AppTheme.error;
      default:
        return AppTheme.outline;
    }
  }

  Color getPriorityTextColor(String priority) {
    switch (priority) {
      case 'normal':
        return AppTheme.onSecondaryContainer;
      case 'medium':
        return AppTheme.priorityOnMedium;
      case 'high':
        return AppTheme.priorityOnHigh;
      case 'urgent':
        return AppTheme.onError;
      default:
        return AppTheme.onSurface;
    }
  }
}
