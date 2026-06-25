import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _successMessage = null;
    });

    try {
      // Convert username to email format jika user input username
      String email = _emailController.text.trim();

      // Jika input tidak mengandung @, berarti user input username
      if (!email.contains('@')) {
        email = '${email.toLowerCase()}@helpdesk.com';
      }

      await ref.read(authProvider.notifier).resetPassword(email: email);

      if (mounted) {
        setState(() {
          _successMessage = 'Email reset password telah dikirim ke $email';
          _isLoading = false;
        });

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.tertiary,
                  size: 28,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                const Text('Email Terkirim'),
              ],
            ),
            content: Text(
              'Link reset password telah dikirim ke $email\n\nSilakan cek inbox Anda dan klik link untuk reset password.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Back to login
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.error,
                  color: AppTheme.error,
                  size: 28,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                const Text('Error'),
              ],
            ),
            content: Text(
              'Gagal mengirim email reset password: ${e.toString()}',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
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
      }
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
          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceVariant),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Lupa Password',
          style: AppTheme.titleLarge.copyWith(color: AppTheme.primary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppTheme.spacingLg),

                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                  child: Icon(
                    Icons.lock_reset,
                    size: 40,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),

                // Title
                Text(
                  'Lupa Password?',
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingSm),

                // Subtitle
                Text(
                  'Masukkan username atau email Anda untuk menerima link reset password',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingXl),

                // Email/Username Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Username atau Email',
                    hintText: 'Contoh: johndoe atau johndoe@helpdesk.com',
                    labelStyle: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppTheme.primary.withValues(alpha: 0.7),
                    ),
                    filled: true,
                    fillColor: AppTheme.surfaceContainerLowest,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      borderSide: const BorderSide(
                        color: AppTheme.outline,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      borderSide: const BorderSide(
                        color: AppTheme.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      borderSide: const BorderSide(
                        color: AppTheme.error,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      borderSide: const BorderSide(
                        color: AppTheme.error,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingLg,
                      vertical: 18,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username atau email wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingSm),

                // Info text
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
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
                        Icons.info_outline,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: Text(
                          'Jika Anda memasukkan username, sistem akan mengkonversi menjadi format username@helpdesk.com',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXl),

                // Reset Password Button
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryContainer,
                      foregroundColor: AppTheme.onPrimary,
                      elevation: AppTheme.elevationLevel1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: AppTheme.onPrimary,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Kirim Link Reset Password',
                            style: AppTheme.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),

                // Back to Login
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                  ),
                  child: Text(
                    'Kembali ke Login',
                    style: AppTheme.labelLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
