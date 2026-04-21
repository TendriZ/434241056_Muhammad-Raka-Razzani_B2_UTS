import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final authState = ref.read(authProvider);
        
        // Jika user tidak null (sudah login session), langsung ke home
        if (authState.value != null) {
          context.go('/home');
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


