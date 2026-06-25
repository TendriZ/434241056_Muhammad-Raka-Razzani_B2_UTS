import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    // Navigate after delay
    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        final authState = ref.read(authProvider);

        // Jika user tidak null (sudah login session), arahkan sesuai ROLE
        if (authState.value != null) {
          try {
            final supabase = ref.read(supabaseClientProvider);
            final profileData = await supabase
                .from('profiles')
                .select('role')
                .eq('id', authState.value!.id)
                .maybeSingle();

            if (!mounted) return;

            final role = profileData?['role'] ?? 'user';

            if (role == 'admin') {
              context.go('/admin');
            } else if (role == 'helpdesk') {
              context.go('/helpdesk');
            } else {
              context.go('/home');
            }
          } catch (e) {
            if (mounted) context.go('/home'); // Fallback jika gagal ambil role
          }
        } else {
          // Jika null, ke login page
          context.go('/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary,
              AppTheme.primaryContainer,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _opacityAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.onPrimary,
                          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.support_agent,
                          size: 60,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),

                      // App Name
                      Text(
                        'E-Ticketing',
                        style: AppTheme.headlineLarge.copyWith(
                          color: AppTheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Helpdesk System',
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXl),

                      // Loading Indicator
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),

                      // Tagline
                      Text(
                        'Solusi Cepat untuk Kendala IT Anda',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.onPrimary.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
