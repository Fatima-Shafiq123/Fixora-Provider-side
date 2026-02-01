import 'package:flutter/material.dart';

/// Custom theme constants and utilities for the Service Link app
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Primary Colors
  static const Color primaryColor = Color(0xFF218907);
  static const Color primaryColorDark = Color(0xFF218907);
  static const Color secondaryColor = Color(0xFF218907);

  // Accent Colors
  static const Color accentColor = Color(0xFF5C5CFF);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Colors.white;
  static const Color lightCardColor = Colors.white;
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightDivider = Color(0xFFE0E0E0);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF2C2C2C);
  static const Color darkCardColor = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkDivider = Color(0xFF3E3E3E);

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusSM = 4.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusRound = 50.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Icon Sizes
  static const double iconSizeSM = 16.0;
  static const double iconSizeMD = 24.0;
  static const double iconSizeLG = 32.0;
  static const double iconSizeXL = 48.0;

  // Font Sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeMD = 14.0;
  static const double fontSizeLG = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 24.0;
  static const double fontSizeXXXL = 32.0;

  // Font Weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  /// Get text theme based on brightness
  static TextTheme getTextTheme(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const TextTheme(
        displayLarge: TextStyle(
          fontSize: fontSizeXXXL,
          fontWeight: fontWeightBold,
          color: darkTextPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: fontSizeXXL,
          fontWeight: fontWeightBold,
          color: darkTextPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: fontSizeXL,
          fontWeight: fontWeightSemiBold,
          color: darkTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: fontSizeXL,
          fontWeight: fontWeightSemiBold,
          color: darkTextPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: fontSizeLG,
          fontWeight: fontWeightMedium,
          color: darkTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: fontSizeLG,
          fontWeight: fontWeightSemiBold,
          color: darkTextPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: fontSizeMD,
          fontWeight: fontWeightMedium,
          color: darkTextPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: fontSizeSM,
          fontWeight: fontWeightMedium,
          color: darkTextSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSizeLG,
          fontWeight: fontWeightRegular,
          color: darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSizeMD,
          fontWeight: fontWeightRegular,
          color: darkTextPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: fontSizeSM,
          fontWeight: fontWeightRegular,
          color: darkTextSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: fontSizeMD,
          fontWeight: fontWeightMedium,
          color: darkTextPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: fontSizeSM,
          fontWeight: fontWeightMedium,
          color: darkTextSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: fontSizeXS,
          fontWeight: fontWeightRegular,
          color: darkTextSecondary,
        ),
      );
    } else {
      return TextTheme(
        displayLarge: TextStyle(
          fontSize: fontSizeXXXL,
          fontWeight: fontWeightBold,
          color: lightTextPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: fontSizeXXL,
          fontWeight: fontWeightBold,
          color: lightTextPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: fontSizeXL,
          fontWeight: fontWeightSemiBold,
          color: lightTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: fontSizeXL,
          fontWeight: fontWeightSemiBold,
          color: lightTextPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: fontSizeLG,
          fontWeight: fontWeightMedium,
          color: lightTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: fontSizeLG,
          fontWeight: fontWeightSemiBold,
          color: lightTextPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: fontSizeMD,
          fontWeight: fontWeightMedium,
          color: lightTextPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: fontSizeSM,
          fontWeight: fontWeightMedium,
          color: lightTextSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSizeLG,
          fontWeight: fontWeightRegular,
          color: lightTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSizeMD,
          fontWeight: fontWeightRegular,
          color: lightTextPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: fontSizeSM,
          fontWeight: fontWeightRegular,
          color: lightTextSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: fontSizeMD,
          fontWeight: fontWeightMedium,
          color: lightTextPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: fontSizeSM,
          fontWeight: fontWeightMedium,
          color: lightTextSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: fontSizeXS,
          fontWeight: fontWeightRegular,
          color: lightTextSecondary,
        ),
      );
    }
  }

  /// Get card theme based on brightness
  static CardTheme getCardTheme(Brightness brightness) {
    return CardTheme(
      color: brightness == Brightness.dark ? darkCardColor : lightCardColor,
      elevation: elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLG),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: spacingMD,
        vertical: spacingSM,
      ),
    );
  }

  /// Get button theme based on brightness
  static ButtonThemeData getButtonTheme(Brightness brightness) {
    return ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMD),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: spacingLG,
        vertical: spacingMD,
      ),
    );
  }

  /// Get input decoration theme based on brightness
  static InputDecorationTheme getInputDecorationTheme(Brightness brightness) {
    return InputDecorationTheme(
      filled: true,
      fillColor: brightness == Brightness.dark ? darkSurface : lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: BorderSide(
          color: brightness == Brightness.dark ? darkDivider : lightDivider,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: BorderSide(
          color: brightness == Brightness.dark ? darkDivider : lightDivider,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(
          color: errorColor,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(
          color: errorColor,
          width: 2.0,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingMD,
        vertical: spacingMD,
      ),
    );
  }

  /// Get app bar theme based on brightness
  static AppBarTheme getAppBarTheme(Brightness brightness) {
    return AppBarTheme(
      backgroundColor: brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontSize: fontSizeXL,
        fontWeight: fontWeightMedium,
        color: Colors.white,
      ),
    );
  }

  /// Get bottom navigation bar theme based on brightness
  static BottomNavigationBarThemeData getBottomNavBarTheme(
      Brightness brightness) {
    return BottomNavigationBarThemeData(
      backgroundColor: brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : lightSurface,
      selectedItemColor:
          brightness == Brightness.dark ? primaryColorDark : primaryColor,
      unselectedItemColor:
          brightness == Brightness.dark ? Colors.white54 : Colors.grey.shade600,
      type: BottomNavigationBarType.fixed,
      elevation: elevationMedium,
    );
  }

  /// Helper method to get theme-aware color
  static Color getThemeAwareColor(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? darkColor : lightColor;
  }

  /// Helper method to get primary color based on theme
  static Color getPrimaryColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? primaryColorDark : primaryColor;
  }

  /// Helper method to get surface color based on theme
  static Color getSurfaceColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? darkSurface : lightSurface;
  }

  /// Helper method to get text color based on theme
  static Color getTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;
  }

  /// Helper method to get secondary text color based on theme
  static Color getSecondaryTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }
}
