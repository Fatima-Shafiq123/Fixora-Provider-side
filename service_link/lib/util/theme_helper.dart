import 'package:flutter/material.dart';

/// A helper class to provide theme-aware styling for various UI components
class ThemeHelper {
  /// Returns the appropriate text color based on the current theme brightness
  static Color getTextColor(BuildContext context, {bool isSecondary = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isSecondary) {
      return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    }
    return isDark ? Colors.white : Colors.black;
  }

  /// Returns the appropriate card color based on the current theme brightness
  static Color getCardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF2C2C2C) : Colors.white;
  }

  /// Returns the appropriate background color based on the current theme brightness
  static Color getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF121212) : Colors.grey.shade100;
  }

  /// Returns the appropriate shadow color based on the current theme brightness
  static BoxShadow getBoxShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxShadow(
      color: isDark 
          ? Colors.black.withOpacity(0.3) 
          : Colors.grey.withOpacity(0.1),
      spreadRadius: 1,
      blurRadius: 3,
      offset: const Offset(0, 1),
    );
  }

  /// Returns the appropriate divider color based on the current theme brightness
  static Color getDividerColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF3E3E3E) : Colors.grey.shade300;
  }
}
