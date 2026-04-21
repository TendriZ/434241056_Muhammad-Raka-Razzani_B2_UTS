import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        automaticallyImplyLeading: false, // Menghilangkan tombol kembali di navbar bawah (home)
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Menjalankan fungsi Logout dari Provider
              await ref.read(authProvider.notifier).logout();
              
              if (context.mounted) {
                // Arahkan paksa kembali ke halaman login
                context.go('/login');
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            profileAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => Text('Error: $err'),
              data: (profile) => Column(
                children: [
                  Text(
                    profile?['full_name'] ?? 'User Baru',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    profile?['username'] != null ? '@${profile!['username']}' : '@username',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Tiket Dibuat', style: TextStyle(fontSize: 16)),
                    Text(
                      profileAsync.value?['ticket_count'] != null
                          ? '${profileAsync.value!['ticket_count']}'
                          : '0',
                      style: TextStyle(fontSize: 14, color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (val) {
                  // Memanggil toggleTheme dari provider
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Bantuan & Pendukung'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const AboutDialog(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Tentang Aplikasi'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const AboutDialog(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

