import 'package:flutter/material.dart';
import '../models/letter_status.dart';
import '../controllers/game_controller.dart';

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
      return const Color(0xFFD3D6DA);
    }

    final status = controller.getKeyStatus(key);
    switch (status) {
      case LetterStatus.correct:
        return const Color(0xFF6AAA64); // Green
      case LetterStatus.present:
        return const Color(0xFFC9B458); // Yellow
      case LetterStatus.absent:
        return const Color(0xFF787C7E); // Gray
      case LetterStatus.empty:
        return const Color(0xFFD3D6DA); // Light gray
    }
  }

  Color _getKeyTextColor(String key) {
    if (key == 'ENTER' || key == '⌫') {
      return Colors.black;
    }

    final status = controller.getKeyStatus(key);
    return status == LetterStatus.empty ? Colors.black : Colors.white;
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
      padding: const EdgeInsets.all(2.0),
      child: Material(
        color: _getKeyColor(key, context),
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: () => _handleKeyPress(key),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: isWide ? 65 : 43,
            height: 58,
            alignment: Alignment.center,
            child: Text(
              key,
              style: TextStyle(
                fontSize: key == 'ENTER' ? 12 : 18,
                fontWeight: FontWeight.bold,
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
