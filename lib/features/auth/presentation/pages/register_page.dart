import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Daftar Akun',
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
                    Icons.person_add_rounded,
                    size: 40,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),

                Text(
                  'Buat Akun Baru',
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  'Silakan lengkapi data berikut untuk mendaftar',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingXl),

                // Form Card
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    border: Border.all(color: AppTheme.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Nama Lengkap',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        icon: Icons.account_circle,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingLg),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                await ref.read(authProvider.notifier).register(
                                  name: _nameController.text,
                                  username: _usernameController.text,
                                  password: _passwordController.text,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Pendaftaran Berhasil!'),
                                      backgroundColor: AppTheme.tertiaryContainer,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                      ),
                                    ),
                                  );
                                  context.go('/home');
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Pendaftaran gagal: $e'),
                                      backgroundColor: AppTheme.error,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryContainer,
                            foregroundColor: AppTheme.onPrimary,
                            elevation: AppTheme.elevationLevel1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            ),
                          ),
                          child: Text(
                            'DAFTAR',
                            style: AppTheme.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun?',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                      ),
                      child: Text(
                        'Login di sini',
                        style: AppTheme.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      style: AppTheme.bodyLarge.copyWith(
        color: AppTheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.bodyMedium.copyWith(
          color: AppTheme.onSurfaceVariant,
        ),
        prefixIcon: Icon(
          icon,
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
    );
  }
}
