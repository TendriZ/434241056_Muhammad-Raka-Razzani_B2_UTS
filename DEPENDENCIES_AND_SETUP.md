# Update pubspec.yaml with these dependencies
# Add these lines to your pubspec.yaml file under dependencies:

dependencies:
  flutter:
    sdk: flutter
  
  # State Management & Architecture
  flutter_bloc: ^8.1.5
  equatable: ^2.0.5
  get_it: ^7.6.0
  
  # Backend & Database
  supabase_flutter: ^1.10.0
  
  # File & Media Handling (FR-005.2)
  image_picker: ^1.0.0
  file_picker: ^5.3.0  # Optional: for file picker
  
  # UI Components
  cupertino_icons: ^1.0.2
  
  # Utilities
  intl: ^0.19.0  # For date formatting
  uuid: ^4.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code generation & analysis
  build_runner: ^2.4.0
  flutter_lints: ^3.0.0

---

# Commands to run after updating pubspec.yaml:

# 1. Get dependencies
flutter pub get

# 2. Analyze code
flutter analyze

# 3. Run app
flutter run

# 4. Build APK (Android)
flutter build apk --release

# 5. Build iOS
flutter build ios --release

---

# Add to your main.dart:

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/features/ticket/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  // Setup Ticket dependencies
  setupTicketDependencies();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Ticketing Helpdesk',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
