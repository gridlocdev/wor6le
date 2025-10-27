import 'package:flutter/material.dart';

class AppColors {
  // Tile colors
  static const Color correct = Color(0xFF6AAA64);
  static const Color present = Color(0xFFC9B458);
  static const Color absent = Color(0xFF787C7E);
  static const Color emptyBorder = Color(0xFFD3D6DA);
  static const Color filledBorder = Color(0xFF878A8C);

  // Keyboard colors
  static const Color keyBackground = Color(0xFFD3D6DA);

  // Text colors
  static const Color textDark = Colors.black;
  static const Color textLight = Colors.white;

  // Background
  static const Color background = Colors.white;
  static const Color appBarBackground = Colors.white;
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
