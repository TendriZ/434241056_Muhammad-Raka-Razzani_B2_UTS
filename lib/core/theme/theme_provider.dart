import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notifier untuk mengatur true = Dark Mode, false = Light Mode
class ThemeModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false; // Default Light Mode
  }

  void toggleTheme() {
    state = !state;
  }
}

// Provider yang akan dibaca oleh UI untuk menentukan ThemeMode
final themeModeProvider = NotifierProvider<ThemeModeNotifier, bool>(() {
  return ThemeModeNotifier();
});

