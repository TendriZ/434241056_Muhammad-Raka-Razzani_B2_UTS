import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/supabase_service.dart';
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

  final List<({String name, List<int> bytes})> _attachments = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ─── Buka Kamera (FR-005.2) ───────────────────────────────────────────────
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
              backgroundColor: Colors.green,
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

  // ─── Buka File Manager / Galeri (FR-005.2) ───────────────────────────────
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
              backgroundColor: Colors.green,
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

  // ─── Submit Tiket ─────────────────────────────────────────────────────────
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
      }).select().single();

      final ticketId = ticketResponse['id'].toString();

      // Mulai upload file pertama (jika ada) dan update ke tabel `tickets` kolom `image_url`
      if (_attachments.isNotEmpty) {
        try {
          final attachment = _attachments.first; // Ambil file pertama saja sebagai representasi utama
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final filePath = 'tickets/$ticketId/$timestamp-${attachment.name}';

          await supabase.storage
              .from('ticket-attachments')
              .uploadBinary(filePath, attachment.bytes as dynamic);
              
          // Dapatkan public URL
          final imageUrl = supabase.storage.from('ticket-attachments').getPublicUrl(filePath);

          // Update data tiket yang baru saja dibuat dengan URL gambar
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
          backgroundColor: Colors.green,
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
      appBar: AppBar(title: const Text('Buat Tiket Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Field Judul
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Masalah',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Field Deskripsi
              TextFormField(
                controller: _descController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Detail',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sertakan deskripsi masalah';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'Unggah Laporan / Bukti (FR-005.2)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // Preview file terpilih
              if (_attachments.isNotEmpty) ...[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _attachments.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final file = _attachments[index];
                      final ext = file.name.split('.').last.toUpperCase();
                      return ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(ext,
                                style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue)),
                          ),
                        ),
                        title: Text(file.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13)),
                        subtitle: Text(
                          '${(file.bytes.length / 1024).toStringAsFixed(1)} KB',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red, size: 18),
                          onPressed: () => _removeAttachment(index),
                          tooltip: 'Hapus file',
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Area kosong
              if (_attachments.isEmpty)
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                    color: Colors.grey.withValues(alpha: 0.05),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined,
                          size: 36, color: Colors.blue.shade400),
                      const SizedBox(height: 6),
                      const Text('Belum ada file terpilih',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              const SizedBox(height: 12),

              // Tombol Kamera & Galeri
              Row(
                children: [
                  // Tombol Kamera
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openCamera,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue.shade700,
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Buka Kamera'),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Tombol Pilih File/Galeri — muncul di semua platform
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickFiles,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue.shade700,
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.photo_library),
                      label: Text(kIsWeb ? 'Pilih File' : 'Pilih Galeri'),
                    ),
                  ),
                ],
              ),

              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => setState(() => _attachments.clear()),
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
                  label: const Text('Hapus Semua File',
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              ],

              const SizedBox(height: 8),
              Text(
                kIsWeb
                    ? 'Format: JPG, PNG, GIF, PDF, DOC (Maks. 10MB per file)'
                    : 'Kamera atau pilih dari galeri (Maks. 10MB per file)',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Tombol Submit
              ElevatedButton(
                onPressed: _isLoading ? null : _submitTicket,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('KIRIM TIKET', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}