import 'package:flutter/material.dart';

/// Design System dari Stitch untuk E-Ticketing Helpdesk
/// Based on Material Design 3 principles
class AppTheme {
  // ============================================
  // COLOR PALETTE (from DESIGN.md)
  // ============================================

  // Primary Colors
  static const Color primary = Color(0xFF0061A4);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF2196F3);
  static const Color onPrimaryContainer = Color(0xFF002C4F);

  // Secondary Colors (Amber/Gold)
  static const Color secondary = Color(0xFF785900);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFDC003);
  static const Color onSecondaryContainer = Color(0xFF6C5000);

  // Tertiary Colors (Green)
  static const Color tertiary = Color(0xFF006E1C);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF42A547);
  static const Color onTertiaryContainer = Color(0xFF003308);

  // Error Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Surface Colors
  static const Color surface = Color(0xFFFBF9F9);
  static const Color onSurface = Color(0xFF1B1C1C);
  static const Color surfaceDim = Color(0xFFDBDAD9);
  static const Color surfaceBright = Color(0xFFFBF9F9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F3F3);
  static const Color surfaceContainer = Color(0xFFEFEDED);
  static const Color surfaceContainerHigh = Color(0xFFE9E8E7);
  static const Color surfaceContainerHighest = Color(0xFFE3E2E2);
  static const Color surfaceVariant = Color(0xFFE3E2E2);

  // Background Colors
  static const Color background = Color(0xFFFBF9F9);
  static const Color onBackground = Color(0xFF1B1C1C);

  // Inverse Colors
  static const Color inverseSurface = Color(0xFF303031);
  static const Color inverseOnSurface = Color(0xFFF2F0F0);
  static const Color inversePrimary = Color(0xFF9ECAFF);

  // Outline Colors
  static const Color outline = Color(0xFF707883);
  static const Color outlineVariant = Color(0xFFBFC7D4);

  // Surface Tint
  static const Color surfaceTint = Color(0xFF0061A4);

  // On Surface Variant
  static const Color onSurfaceVariant = Color(0xFF404752);

  // Status Colors (Semantic)
  static const Color statusOpen = Color(0xFFFDC003); // Secondary Container
  static const Color statusOnOpen = Color(0xFF6C5000); // On Secondary Container
  static const Color statusInProgress = Color(0xFF2196F3); // Primary Container
  static const Color statusOnInProgress = Color(0xFFFFFFFF); // On Primary
  static const Color statusResolved = Color(0xFF42A547); // Tertiary Container
  static const Color statusOnResolved = Color(0xFF003308); // On Tertiary Container
  static const Color statusClosed = Color(0xFFD2F8D2); // Custom Success
  static const Color statusOnClosed = Color(0xFF005313); // Custom Success

  // Priority Colors
  static const Color priorityNormal = Color(0xFFFDC003); // Secondary Container
  static const Color priorityOnNormal = Color(0xFF6C5000);
  static const Color priorityMedium = Color(0xFFFFDF9E); // Secondary Fixed
  static const Color priorityOnMedium = Color(0xFF5B4300);
  static const Color priorityHigh = Color(0xFFFFDAD6); // Error Container
  static const Color priorityOnHigh = Color(0xFF93000A);
  static const Color priorityUrgent = Color(0xFFBA1A1A); // Error
  static const Color priorityOnUrgent = Color(0xFFFFFFFF);

  // ============================================
  // TYPOGRAPHY (from DESIGN.md)
  // ============================================

  static const String fontFamily = 'Roboto';

  // Display Styles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 64 / 57,
  );

  // Headline Styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 40 / 32,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 36 / 28,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 32 / 24,
  );

  // Title Styles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 28 / 22,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 24 / 16,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 20 / 14,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 24 / 16,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 20 / 14,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 16 / 12,
  );

  // Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 20 / 14,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 16 / 12,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 16 / 11,
  );

  // ============================================
  // BORDER RADIUS (from DESIGN.md)
  // ============================================

  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusFull = 9999.0;

  // ============================================
  // SPACING (from DESIGN.md - 8px grid)
  // ============================================

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // ============================================
  // ELEVATION
  // ============================================

  static const double elevationLevel0 = 0.0;
  static const double elevationLevel1 = 1.0;
  static const double elevationLevel2 = 2.0;
  static const double elevationLevel3 = 3.0;
  static const double elevationLevel4 = 4.0;

  // ============================================
  // LIGHT THEME
  // ============================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        background: background,
        onBackground: onBackground,
        surface: surface,
        onSurface: onSurface,
        surfaceVariant: surfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        inverseSurface: inverseSurface,
        onInverseSurface: inverseOnSurface,
        inversePrimary: inversePrimary,
      ),

      // Scaffold
      scaffoldBackgroundColor: background,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: elevationLevel1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: primary,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceContainerLowest,
        elevation: elevationLevel1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: labelLarge.copyWith(color: onSurfaceVariant),
        hintStyle: bodyMedium.copyWith(color: onSurfaceVariant),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryContainer,
          foregroundColor: onPrimary,
          elevation: elevationLevel1,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: labelLarge.copyWith(fontWeight: FontWeight.w500),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          side: const BorderSide(color: outline, width: 1),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryContainer,
        foregroundColor: onPrimary,
        elevation: elevationLevel3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainerLow,
        selectedColor: secondaryContainer,
        labelStyle: labelMedium.copyWith(color: onSurface),
        secondaryLabelStyle: labelMedium.copyWith(color: onSecondaryContainer),
        padding: const EdgeInsets.symmetric(horizontal: spacingSm, vertical: spacingSm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        side: const BorderSide(color: outline, width: 1),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: surfaceVariant,
        thickness: 1,
        space: 1,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryContainer,
        unselectedItemColor: onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: elevationLevel1,
        selectedLabelStyle: labelSmall.copyWith(color: primaryContainer),
        unselectedLabelStyle: labelSmall.copyWith(color: onSurfaceVariant),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: onSurfaceVariant,
        size: 24,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: elevationLevel2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        titleTextStyle: headlineSmall.copyWith(color: onSurface),
        contentTextStyle: bodyMedium.copyWith(color: onSurfaceVariant),
      ),
    );
  }

  // ============================================
  // DARK THEME
  // ============================================

  // Dark theme palette
  static const Color darkBackground = Color(0xFF1B1C1C);
  static const Color darkOnBackground = Color(0xFFE3E2E2);
  static const Color darkSurface = Color(0xFF1B1C1C);
  static const Color darkOnSurface = Color(0xFFE3E2E2);
  static const Color darkPrimary = Color(0xFF9ECAFF);
  static const Color darkOnPrimary = Color(0xFFFFFFFF);
  static const Color darkPrimaryContainer = Color(0xFF004A7C);
  static const Color darkOnPrimaryContainer = Color(0xFFD1E4FF);
  static const Color darkSecondary = Color(0xFFF5BF48);
  static const Color darkOnSecondary = Color(0xFFFFFFFF);
  static const Color darkSecondaryContainer = Color(0xFF544000);
  static const Color darkOnSecondaryContainer = Color(0xFFFFDEA1);
  static const Color darkTertiary = Color(0xFF6DD68B);
  static const Color darkOnTertiary = Color(0xFFFFFFFF);
  static const Color darkTertiaryContainer = Color(0xFF005318);
  static const Color darkOnTertiaryContainer = Color(0xFF96F5B1);
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFFFFFFFF);
  static const Color darkErrorContainer = Color(0xFF93000A);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);
  static const Color darkOutline = Color(0xFF8C919C);
  static const Color darkOutlineVariant = Color(0xFF424851);
  static const Color darkOnSurfaceVariant = Color(0xFFD4D6E0);
  static const Color darkSurfaceDim = Color(0xFF1B1C1C);
  static const Color darkSurfaceBright = Color(0xFF424242);
  static const Color darkSurfaceContainerLowest = Color(0xFF111111);
  static const Color darkSurfaceContainerLow = Color(0xFF1E1E1E);
  static const Color darkSurfaceContainer = Color(0xFF252525);
  static const Color darkSurfaceContainerHigh = Color(0xFF303030);
  static const Color darkSurfaceContainerHighest = Color(0xFF3C3C3C);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        onPrimary: darkOnPrimary,
        primaryContainer: darkPrimaryContainer,
        onPrimaryContainer: darkOnPrimaryContainer,
        secondary: darkSecondary,
        onSecondary: darkOnSecondary,
        secondaryContainer: darkSecondaryContainer,
        onSecondaryContainer: darkOnSecondaryContainer,
        tertiary: darkTertiary,
        onTertiary: darkOnTertiary,
        tertiaryContainer: darkTertiaryContainer,
        onTertiaryContainer: darkOnTertiaryContainer,
        error: darkError,
        onError: darkOnError,
        errorContainer: darkErrorContainer,
        onErrorContainer: darkOnErrorContainer,
        surface: darkSurface,
        onSurface: darkOnSurface,
        surfaceDim: darkSurfaceDim,
        surfaceBright: darkSurfaceBright,
        surfaceContainerLowest: darkSurfaceContainerLowest,
        surfaceContainerLow: darkSurfaceContainerLow,
        surfaceContainer: darkSurfaceContainer,
        surfaceContainerHigh: darkSurfaceContainerHigh,
        surfaceContainerHighest: darkSurfaceContainerHighest,
        outline: darkOutline,
        outlineVariant: darkOutlineVariant,
      ),

      scaffoldBackgroundColor: darkBackground,

      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        elevation: elevationLevel1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: darkPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: darkSurfaceContainerLow,
        elevation: elevationLevel1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceContainerHigh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: darkOutline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: darkOutline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: darkError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: darkError, width: 2),
        ),
        labelStyle: labelLarge.copyWith(color: darkOnSurfaceVariant),
        hintStyle: bodyMedium.copyWith(color: darkOnSurfaceVariant),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryContainer,
          foregroundColor: darkOnPrimaryContainer,
          elevation: elevationLevel1,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: labelLarge.copyWith(fontWeight: FontWeight.w500),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          side: const BorderSide(color: darkOutline, width: 1),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkPrimaryContainer,
        foregroundColor: darkOnPrimaryContainer,
        elevation: elevationLevel3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceContainerHigh,
        selectedColor: darkPrimaryContainer,
        labelStyle: labelMedium.copyWith(color: darkOnSurface),
        secondaryLabelStyle: labelMedium.copyWith(color: darkOnSecondaryContainer),
        padding: const EdgeInsets.symmetric(horizontal: spacingSm, vertical: spacingSm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        side: const BorderSide(color: darkOutline, width: 1),
      ),

      dividerTheme: const DividerThemeData(
        color: darkOutlineVariant,
        thickness: 1,
        space: 1,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceContainerLow,
        selectedItemColor: darkPrimary,
        unselectedItemColor: darkOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: elevationLevel1,
        selectedLabelStyle: labelSmall.copyWith(color: darkPrimary, fontWeight: FontWeight.w600),
        unselectedLabelStyle: labelSmall.copyWith(color: darkOnSurfaceVariant),
      ),

      iconTheme: const IconThemeData(
        color: darkOnSurfaceVariant,
        size: 24,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: darkSurfaceContainerLow,
        elevation: elevationLevel2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        titleTextStyle: headlineSmall.copyWith(color: darkOnSurface),
        contentTextStyle: bodyMedium.copyWith(color: darkOnSurfaceVariant),
      ),
    );
  }

  // ============================================
  // CUSTOM WIDGET STYLES
  // ============================================

  /// Status Badge Style
  static BoxDecoration getStatusBadgeStyle(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'open':
        return BoxDecoration(
          color: statusOpen,
          borderRadius: BorderRadius.circular(radiusMd),
        );
      case 'on_progress':
      case 'inprogress':
        return BoxDecoration(
          color: statusInProgress,
          borderRadius: BorderRadius.circular(radiusMd),
        );
      case 'resolved':
      case 'closed':
        return BoxDecoration(
          color: statusClosed,
          borderRadius: BorderRadius.circular(radiusMd),
        );
      default:
        return BoxDecoration(
          color: surfaceVariant,
          borderRadius: BorderRadius.circular(radiusMd),
        );
    }
  }

  /// Priority Badge Color (for chip styling)
  static Color getPriorityBadgeColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'normal':
        return secondaryContainer;
      case 'medium':
        return priorityMedium;
      case 'high':
        return errorContainer;
      case 'urgent':
        return error;
      default:
        return surfaceVariant;
    }
  }

  /// Priority Border Color
  static Color getPriorityBorderColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'normal':
        return secondaryContainer;
      case 'medium':
        return priorityMedium;
      case 'high':
        return errorContainer;
      case 'urgent':
        return error;
      default:
        return outline;
    }
  }

  /// Priority Badge Style
  static BoxDecoration getPriorityBadgeStyle(String priority) {
    switch (priority.toLowerCase()) {
      case 'normal':
        return BoxDecoration(
          color: priorityNormal,
          borderRadius: BorderRadius.circular(radiusFull),
        );
      case 'medium':
        return BoxDecoration(
          color: priorityMedium,
          borderRadius: BorderRadius.circular(radiusFull),
        );
      case 'high':
        return BoxDecoration(
          color: priorityHigh,
          borderRadius: BorderRadius.circular(radiusFull),
        );
      case 'urgent':
        return BoxDecoration(
          color: priorityUrgent,
          borderRadius: BorderRadius.circular(radiusFull),
        );
      default:
        return BoxDecoration(
          color: surfaceVariant,
          borderRadius: BorderRadius.circular(radiusFull),
        );
    }
  }

  /// Get text color for status badge
  static Color getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'open':
        return statusOnOpen;
      case 'on_progress':
      case 'inprogress':
        return statusOnInProgress;
      case 'resolved':
      case 'closed':
        return statusOnClosed;
      default:
        return onSurface;
    }
  }

  /// Get text color for priority badge
  static Color getPriorityTextColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'normal':
        return priorityOnNormal;
      case 'medium':
        return priorityOnMedium;
      case 'high':
        return priorityOnHigh;
      case 'urgent':
        return priorityOnUrgent;
      default:
        return onSurface;
    }
  }
}
