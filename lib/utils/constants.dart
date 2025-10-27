import 'package:flutter/material.dart';

class AppColors {
  // Standard colors
  static const Color correct = Color(0xFF6AAA64);
  static const Color present = Color(0xFFC9B458);
  static const Color absent = Color(0xFF787C7E);

  // Color blind mode colors (high contrast)
  static const Color correctColorBlind = Color(0xFFF5793A); // Orange
  static const Color presentColorBlind = Color(0xFF85C0F9); // Blue
  static const Color absentColorBlind = Color(0xFF787C7E);

  // Light mode colors
  static const Color emptyBorderLight = Color(0xFFD3D6DA);
  static const Color filledBorderLight = Color(0xFF878A8C);
  static const Color keyBackgroundLight = Color(0xFFD3D6DA);
  static const Color textDark = Colors.black;
  static const Color textLight = Colors.white;
  static const Color backgroundLight = Colors.white;
  static const Color appBarBackgroundLight = Colors.white;

  // Dark mode colors
  static const Color emptyBorderDark = Color(0xFF3A3A3C);
  static const Color filledBorderDark = Color(0xFF565758);
  static const Color keyBackgroundDark = Color(0xFF818384);
  static const Color backgroundDark = Color(0xFF121213);
  static const Color appBarBackgroundDark = Color(0xFF121213);

  // Helper methods to get colors based on mode
  static Color getCorrectColor(bool colorBlindMode) {
    return colorBlindMode ? correctColorBlind : correct;
  }

  static Color getPresentColor(bool colorBlindMode) {
    return colorBlindMode ? presentColorBlind : present;
  }

  static Color getAbsentColor(bool colorBlindMode) {
    return colorBlindMode ? absentColorBlind : absent;
  }

  static Color getEmptyBorderColor(bool darkMode) {
    return darkMode ? emptyBorderDark : emptyBorderLight;
  }

  static Color getFilledBorderColor(bool darkMode) {
    return darkMode ? filledBorderDark : filledBorderLight;
  }

  static Color getKeyBackgroundColor(bool darkMode) {
    return darkMode ? keyBackgroundDark : keyBackgroundLight;
  }

  static Color getBackgroundColor(bool darkMode) {
    return darkMode ? backgroundDark : backgroundLight;
  }

  static Color getAppBarBackgroundColor(bool darkMode) {
    return darkMode ? appBarBackgroundDark : appBarBackgroundLight;
  }

  static Color getTextColorForBackground(bool darkMode) {
    return darkMode ? textLight : textDark;
  }
}

class AppSizes {
  // Tile dimensions
  static const double tileSize = 62.0;
  static const double tileGap = 4.0;
  static const double tileBorderWidth = 2.0;
  static const double tileBorderRadius = 4.0;
  static const double tileFontSize = 32.0;

  // Arrow
  static const double arrowSize = 16.0;
  static const double arrowPadding = 2.0;

  // Keyboard
  static const double keyHeight = 58.0;
  static const double keyWidth = 43.0;
  static const double keyWideWidth = 65.0;
  static const double keyGap = 4.0;
  static const double keyFontSize = 18.0;
  static const double keyEnterFontSize = 12.0;

  // Spacing
  static const double gridRowGap = 8.0;
  static const double screenPadding = 20.0;
}

class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    letterSpacing: 2,
  );

  static const TextStyle tileLetter = TextStyle(
    fontSize: AppSizes.tileFontSize,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle keyLetter = TextStyle(
    fontSize: AppSizes.keyFontSize,
    fontWeight: FontWeight.bold,
  );
}
