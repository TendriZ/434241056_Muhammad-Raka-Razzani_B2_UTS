import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Beri jeda 3 detik untuk animasi splash screen, lalu cek status login
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.support_agent, size: 80, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'E-Ticketing Helpdesk',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


