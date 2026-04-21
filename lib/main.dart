import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/app_router.dart';
import 'core/theme/theme_provider.dart';
import 'features/ticket/injection_container.dart';

// Konfigurasi Supabase
const supabaseUrl = 'https://cvmzoczzdqpiucpedghp.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFwaXVjcGVkZ2hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNTgyOTEsImV4cCI6MjA5MTYzNDI5MX0.NVC_if2gR7IiV2E2Z2e222vm7U5dHdGylQl7zGIukUc';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase Client
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  setupTicketDependencies(); // Setup dependency injection untuk Ticket Feature

  runApp(
    // ProviderScope diperlukan agar Riverpod bisa berfungsi
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membaca router dari app_router provider
    final router = ref.watch(routerProvider);
    
    // Membaca state mode tema terang/gelap (true = Dark, false = Light)
    final isDarkMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'E-Ticketing Helpdesk',
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.amber,
        ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}


