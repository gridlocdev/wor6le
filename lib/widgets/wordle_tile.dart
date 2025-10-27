import 'package:flutter/material.dart';
import '../models/tile_state.dart';
import '../models/letter_status.dart';
import '../models/arrow_direction.dart';

class WordleTile extends StatelessWidget {
  final TileState tileState;
  final bool isCurrentRow;

  const WordleTile({
    super.key,
    required this.tileState,
    this.isCurrentRow = false,
  });

  Color _getBackgroundColor() {
    switch (tileState.status) {
      case LetterStatus.correct:
        return const Color(0xFF6AAA64); // Green
      case LetterStatus.present:
        return const Color(0xFFC9B458); // Yellow
      case LetterStatus.absent:
        return const Color(0xFF787C7E); // Gray
      case LetterStatus.empty:
        return Colors.transparent;
    }
  }

  Color _getBorderColor() {
    if (tileState.status != LetterStatus.empty) {
      return Colors.transparent;
    }
    return isCurrentRow && tileState.letter.isNotEmpty
        ? const Color(0xFF878A8C)
        : const Color(0xFFD3D6DA);
  }

  Color _getTextColor() {
    return tileState.status == LetterStatus.empty ? Colors.black : Colors.white;
  }

  Widget _buildArrow() {
    if (tileState.arrowDirection == ArrowDirection.none) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 2,
      right: tileState.arrowDirection == ArrowDirection.right ? 2 : null,
      left: tileState.arrowDirection == ArrowDirection.left ? 2 : null,
      child: Icon(
        tileState.arrowDirection == ArrowDirection.left
            ? Icons.arrow_back
            : Icons.arrow_forward,
        color: Colors.white.withOpacity(0.8),
        size: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        border: Border.all(color: _getBorderColor(), width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              tileState.letter,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _getTextColor(),
              ),
            ),
          ),
          _buildArrow(),
        ],
      ),
    );
  }
}
