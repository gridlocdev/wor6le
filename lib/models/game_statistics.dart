/// Represents player statistics
class GameStatistics {
  final int gamesPlayed;
  final int gamesWon;
  final int currentStreak;
  final int maxStreak;
  final Map<int, int> guessDistribution; // Number of guesses (1-6) -> count

  const GameStatistics({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.guessDistribution = const {},
  });

  double get winPercentage =>
      gamesPlayed > 0 ? (gamesWon / gamesPlayed * 100) : 0;

  GameStatistics copyWith({
    int? gamesPlayed,
    int? gamesWon,
    int? currentStreak,
    int? maxStreak,
    Map<int, int>? guessDistribution,
  }) {
    return GameStatistics(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      guessDistribution: guessDistribution ?? this.guessDistribution,
    );
  }

  Map<String, dynamic> toJson() {
    // Convert guessDistribution int keys to strings for JSON compatibility
    final Map<String, int> stringKeyDistribution = {};
    guessDistribution.forEach((key, value) {
      stringKeyDistribution[key.toString()] = value;
    });

    return {
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'guessDistribution': stringKeyDistribution,
    };
  }

  factory GameStatistics.fromJson(Map<String, dynamic> json) {
    // Handle guessDistribution conversion carefully
    // JSON converts int keys to strings, so we need to convert them back
    final Map<int, int> distribution = {};
    final rawDistribution = json['guessDistribution'];
    if (rawDistribution != null && rawDistribution is Map) {
      rawDistribution.forEach((key, value) {
        final intKey = key is int ? key : int.tryParse(key.toString());
        if (intKey != null && value is int) {
          distribution[intKey] = value;
        }
      });
    }

    return GameStatistics(
      gamesPlayed: json['gamesPlayed'] ?? 0,
      gamesWon: json['gamesWon'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      maxStreak: json['maxStreak'] ?? 0,
      guessDistribution: distribution,
    );
  }
}
