import 'package:flutter/material.dart';
import '../models/letter_status.dart';
import '../controllers/game_controller.dart';
import '../utils/constants.dart';

class GameKeyboard extends StatelessWidget {
  final GameController controller;

  const GameKeyboard({super.key, required this.controller});

  static const List<List<String>> _keyboardLayout = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
  ];

  Color _getKeyColor(String key, BuildContext context) {
    if (key == 'ENTER' || key == '⌫') {
      return AppColors.keyBackground;
    }

    final status = controller.getKeyStatus(key);
    switch (status) {
      case LetterStatus.correct:
        return AppColors.correct;
      case LetterStatus.present:
        return AppColors.present;
      case LetterStatus.absent:
        return AppColors.absent;
      case LetterStatus.empty:
        return AppColors.keyBackground;
    }
  }

  Color _getKeyTextColor(String key) {
    if (key == 'ENTER' || key == '⌫') {
      return AppColors.textDark;
    }

    final status = controller.getKeyStatus(key);
    return status == LetterStatus.empty
        ? AppColors.textDark
        : AppColors.textLight;
  }

  void _handleKeyPress(String key) {
    if (key == 'ENTER') {
      controller.submitGuess();
    } else if (key == '⌫') {
      controller.removeLetter();
    } else {
      controller.addLetter(key);
    }
  }

  Widget _buildKey(String key, BuildContext context) {
    final isWide = key == 'ENTER' || key == '⌫';

    return Padding(
      padding: EdgeInsets.all(AppSizes.keyGap / 2),
      child: Material(
        color: _getKeyColor(key, context),
        borderRadius: BorderRadius.circular(AppSizes.tileBorderRadius),
        child: InkWell(
          onTap: () => _handleKeyPress(key),
          borderRadius: BorderRadius.circular(AppSizes.tileBorderRadius),
          child: Container(
            width: isWide ? AppSizes.keyWideWidth : AppSizes.keyWidth,
            height: AppSizes.keyHeight,
            alignment: Alignment.center,
            child: Text(
              key,
              style: AppTextStyles.keyLetter.copyWith(
                fontSize: key == 'ENTER'
                    ? AppSizes.keyEnterFontSize
                    : AppSizes.keyFontSize,
                color: _getKeyTextColor(key),
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
