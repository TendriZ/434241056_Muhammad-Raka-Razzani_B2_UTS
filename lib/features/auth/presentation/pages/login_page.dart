import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        final role = await ref.read(authProvider.notifier).login(
              username: _usernameController.text,
              password: _passwordController.text,
            );

        // Invalidate profile provider agar tidak nyangkut cache user sebelumnya
        ref.invalidate(userProfileProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Login Berhasil'),
              backgroundColor: AppTheme.tertiaryContainer,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
            ),
          );

          // Diarahkan sesuai dengan ROLE
          if (role == 'admin') {
            context.go('/admin');
          } else if (role == 'helpdesk') {
            context.go('/helpdesk');
          } else {
            context.go('/home');
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login gagal: $e'),
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
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary.withValues(alpha: 0.05),
              AppTheme.surface,
              AppTheme.primaryContainer.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
                vertical: AppTheme.spacingLg,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo Icon
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingLg),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.support_agent_rounded,
                        size: 64,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    Text(
                      'Selamat Datang Kembali!',
                      style: AppTheme.headlineMedium.copyWith(
                        color: AppTheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      'Masuk untuk mengelola tiket Anda',
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
                            controller: _usernameController,
                            label: 'Username',
                            icon: Icons.person_outline_rounded,
                            validator: (value) =>
                                value!.isEmpty ? 'Username wajib diisi' : null,
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password wajib diisi';
                              }
                              if (value.length < 6) return 'Minimal 6 karakter';
                              return null;
                            },
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/forgot-password'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primary,
                              ),
                              child: Text(
                                'Lupa Password?',
                                style: AppTheme.labelLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMd),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryContainer,
                                foregroundColor: AppTheme.onPrimary,
                                elevation: AppTheme.elevationLevel1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: AppTheme.onPrimary,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'MASUK',
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
                          'Belum punya akun?',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                          ),
                          child: Text(
                            'Daftar di sini',
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
      obscureText: isPassword && !_isPasswordVisible,
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
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppTheme.onSurfaceVariant,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
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
