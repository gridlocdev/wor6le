import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/game_statistics.dart';
import '../models/game_status.dart';
import 'stats_dialog.dart';

class GameOverDialog extends StatelessWidget {
  final GameState gameState;
  final GameStatistics statistics;
  final bool colorBlindMode;
  final bool darkMode;
  final VoidCallback onPlayAgain;
  final VoidCallback onResetStats;

  const GameOverDialog({
    super.key,
    required this.gameState,
    required this.statistics,
    required this.colorBlindMode,
    required this.darkMode,
    required this.onPlayAgain,
    required this.onResetStats,
  });

  @override
  Widget build(BuildContext context) {
    final isWin = gameState.status == GameStatus.won;

    return AlertDialog(
      title: Text(isWin ? 'Congratulations!' : 'Game Over'),
      content: Text(
        isWin
            ? 'You won in ${gameState.currentRow} ${gameState.currentRow == 1 ? 'guess' : 'guesses'}!'
            : 'The word was: ${gameState.targetWord}',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (context) => StatsDialog(
                statistics: statistics,
                gameState: gameState,
                colorBlindMode: colorBlindMode,
                darkMode: darkMode,
                onReset: onResetStats,
              ),
            );
          },
          child: const Text('View Stats'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onPlayAgain();
          },
          child: const Text('Play Again'),
        ),
      ],
    );
  }
}
