import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_statistics.dart';
import '../models/game_state.dart';

class StatsDialog extends StatelessWidget {
  final GameStatistics statistics;
  final GameState? gameState;

  const StatsDialog({
    super.key,
    required this.statistics,
    this.gameState,
  });

  String _generateShareText() {
    if (gameState == null || !gameState!.isGameOver) {
      return '';
    }

    final isWin = gameState!.status.toString().contains('won');
    final attempts = isWin ? gameState!.currentRow : 'X';
    
    String result = 'Wor6le $attempts/6\n\n';
    
    for (int i = 0; i < gameState!.currentRow && i < 6; i++) {
      for (var tile in gameState!.guesses[i]) {
        switch (tile.status.toString()) {
          case 'LetterStatus.correct':
            result += '🟩';
            break;
          case 'LetterStatus.present':
            result += '🟨';
            break;
          default:
            result += '⬜';
        }
      }
      result += '\n';
    }
    
    return result;
  }

  void _shareResults(BuildContext context) {
    final text = _generateShareText();
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Results copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'STATISTICS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  statistics.gamesPlayed.toString(),
                  'Played',
                ),
                _buildStatItem(
                  statistics.winPercentage.toStringAsFixed(0),
                  'Win %',
                ),
                _buildStatItem(
                  statistics.currentStreak.toString(),
                  'Current\nStreak',
                ),
                _buildStatItem(
                  statistics.maxStreak.toString(),
                  'Max\nStreak',
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'GUESS DISTRIBUTION',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(6, (index) {
              final guessNum = index + 1;
              final count = statistics.guessDistribution[guessNum] ?? 0;
              final maxCount = statistics.guessDistribution.values.fold<int>(
                0,
                (max, value) => value > max ? value : max,
              );
              final percentage = maxCount > 0 ? count / maxCount : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 12,
                      child: Text(
                        guessNum.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: count > 0
                              ? const Color(0xFF6AAA64)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 20,
                          maxWidth: MediaQuery.of(context).size.width * 
                                   percentage.clamp(0.1, 1.0),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (gameState != null && gameState!.isGameOver) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _shareResults(context),
                  icon: const Icon(Icons.share),
                  label: const Text('SHARE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6AAA64),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
