/// Represents the status of a letter in a guess
enum LetterStatus {
  /// Letter is in the correct position
  correct,

  /// Letter is in the word but in wrong position
  present,

  /// Letter is not in the word
  absent,

  /// Letter hasn't been evaluated yet
  empty,
}
