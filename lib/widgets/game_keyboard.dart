import 'package:flutter/material.dart';
import '../models/letter_status.dart';
import '../controllers/game_controller.dart';
import '../utils/constants.dart';

class GameKeyboard extends StatelessWidget {
  final GameController controller;
  final VoidCallback? onInvalidGuess;
  final bool colorBlindMode;
  final bool darkMode;

  const GameKeyboard({
    super.key,
    required this.controller,
    this.onInvalidGuess,
    this.colorBlindMode = false,
    this.darkMode = false,
  });

  static const List<List<String>> _keyboardLayout = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
  ];

  Color _getKeyColor(String key, BuildContext context) {
    if (key == 'ENTER' || key == '⌫') {
      return AppColors.getKeyBackgroundColor(darkMode);
    }

    final status = controller.getKeyStatus(key);
    switch (status) {
      case LetterStatus.correct:
        return AppColors.getCorrectColor(colorBlindMode);
      case LetterStatus.present:
        return AppColors.getPresentColor(colorBlindMode);
      case LetterStatus.absent:
        return AppColors.getAbsentColor(colorBlindMode);
      case LetterStatus.empty:
        return AppColors.getKeyBackgroundColor(darkMode);
    }
  }

  Color _getKeyTextColor(String key) {
    if (key == 'ENTER' || key == '⌫') {
      return AppColors.getTextColorForBackground(darkMode);
    }

    final status = controller.getKeyStatus(key);
    return status == LetterStatus.empty
        ? AppColors.getTextColorForBackground(darkMode)
        : AppColors.textLight;
  }

  void _handleKeyPress(String key, BuildContext context) async {
    if (key == 'ENTER') {
      final error = await controller.submitGuess();
      if (error != null && context.mounted) {
        onInvalidGuess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            duration: const Duration(milliseconds: 800),
            backgroundColor: Colors.black87,
          ),
        );
      }
    } else if (key == '⌫') {
      controller.removeLetter();
    } else {
      controller.addLetter(key);
    }
  }

  Widget _buildKey(String key, BuildContext context) {
    final isWide = key == 'ENTER' || key == '⌫';
    final status = controller.getKeyStatus(key);
    final isAbsent = status == LetterStatus.absent;

    return Padding(
      padding: EdgeInsets.all(AppSizes.keyGap / 2),
      child: AnimatedOpacity(
        opacity: isAbsent ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isWide ? AppSizes.keyWideWidth : AppSizes.keyWidth,
          height: AppSizes.keyHeight,
          decoration: BoxDecoration(
            color: _getKeyColor(key, context),
            borderRadius: BorderRadius.circular(AppSizes.tileBorderRadius),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleKeyPress(key, context),
              borderRadius: BorderRadius.circular(AppSizes.tileBorderRadius),
              child: Container(
                alignment: Alignment.center,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: AppTextStyles.keyLetter.copyWith(
                    fontSize: key == 'ENTER'
                        ? AppSizes.keyEnterFontSize
                        : AppSizes.keyFontSize,
                    color: _getKeyTextColor(key),
                  ),
                  child: Text(key),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        children: _keyboardLayout.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) => _buildKey(key, context)).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
