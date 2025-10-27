import 'tile_state.dart';
import 'game_status.dart';

/// Represents the complete game state
class GameState {
  final String targetWord;
  final List<List<TileState>> guesses;
  final int currentRow;
  final String currentGuess;
  final GameStatus status;
  final Map<String, int>
  letterCounts; // Track letter occurrences in target word

  const GameState({
    required this.targetWord,
    required this.guesses,
    this.currentRow = 0,
    this.currentGuess = '',
    this.status = GameStatus.playing,
    this.letterCounts = const {},
  });

  GameState copyWith({
    String? targetWord,
    List<List<TileState>>? guesses,
    int? currentRow,
    String? currentGuess,
    GameStatus? status,
    Map<String, int>? letterCounts,
  }) {
    return GameState(
      targetWord: targetWord ?? this.targetWord,
      guesses: guesses ?? this.guesses,
      currentRow: currentRow ?? this.currentRow,
      currentGuess: currentGuess ?? this.currentGuess,
      status: status ?? this.status,
      letterCounts: letterCounts ?? this.letterCounts,
    );
  }

  /// Create initial game state with empty grid
  factory GameState.initial(String targetWord) {
    // Count letter occurrences in target word
    final letterCounts = <String, int>{};
    for (var char in targetWord.split('')) {
      letterCounts[char] = (letterCounts[char] ?? 0) + 1;
    }

    return GameState(
      targetWord: targetWord,
      guesses: List.generate(
        6,
        (_) => List.generate(6, (_) => TileState.empty()),
      ),
      letterCounts: letterCounts,
    );
  }

  /// Check if the game is over
  bool get isGameOver => status != GameStatus.playing;

  /// Get the maximum number of rows (attempts)
  static const int maxAttempts = 6;

  /// Get the word length
  static const int wordLength = 6;
}
