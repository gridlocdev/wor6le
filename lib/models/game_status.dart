/// Represents the current state of the game
enum GameStatus {
  /// Game is in progress
  playing,

  /// Player has won
  won,

  /// Player has lost (used all 6 attempts)
  lost,
}
