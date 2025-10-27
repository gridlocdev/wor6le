import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../models/game_state.dart';
import '../models/tile_state.dart';
import '../models/letter_status.dart';
import '../models/arrow_direction.dart';
import '../models/game_status.dart';

class GameController extends ChangeNotifier {
  GameState _gameState;
  List<String> _validWords = [];
  List<String> _answerWords = [];
  final Random _random = Random();

  GameController(String targetWord)
    : _gameState = GameState.initial(targetWord);

  GameState get gameState => _gameState;

  /// Load word lists from assets
  Future<void> loadWords() async {
    try {
      // Load valid guess words
      final String guessesString = await rootBundle.loadString(
        'assets/guesses.txt',
      );
      _validWords = guessesString
          .split('\n')
          .map((word) => word.trim().toUpperCase())
          .where((word) => word.length == 6)
          .toList();

      // Load answer words (subset used for daily puzzles)
      final String answersString = await rootBundle.loadString(
        'assets/answers.txt',
      );
      _answerWords = answersString
          .split('\n')
          .map((word) => word.trim().toUpperCase())
          .where((word) => word.length == 6)
          .toList();
    } catch (e) {
      debugPrint('Error loading words: $e');
    }
  }

  /// Get daily word based on date
  String getDailyWord(DateTime date) {
    if (_answerWords.isEmpty) {
      return 'FLUTTER'; // Fallback
    }

    // Use date as seed for deterministic random selection
    final daysSinceEpoch = date.difference(DateTime(2025, 1, 1)).inDays;
    final index = daysSinceEpoch % _answerWords.length;
    return _answerWords[index];
  }

  /// Get a random word for a new game
  String getRandomWord() {
    if (_answerWords.isEmpty) {
      return 'FLUTTER'; // Fallback
    }
    final index = _random.nextInt(_answerWords.length);
    return _answerWords[index];
  }

  /// Initialize a new game with a random word
  void initializeNewGame() {
    final randomWord = getRandomWord();
    _gameState = GameState.initial(randomWord);
    notifyListeners();
  }

  /// Add a letter to the current guess
  void addLetter(String letter) {
    if (_gameState.isGameOver) return;
    if (_gameState.currentGuess.length >= GameState.wordLength) return;

    _gameState = _gameState.copyWith(
      currentGuess: _gameState.currentGuess + letter.toUpperCase(),
    );
    notifyListeners();
  }

  /// Remove the last letter from current guess
  void removeLetter() {
    if (_gameState.isGameOver) return;
    if (_gameState.currentGuess.isEmpty) return;

    _gameState = _gameState.copyWith(
      currentGuess: _gameState.currentGuess.substring(
        0,
        _gameState.currentGuess.length - 1,
      ),
    );
    notifyListeners();
  }

  /// Submit the current guess
  Future<String?> submitGuess() async {
    if (_gameState.isGameOver) return 'Game is over';
    if (_gameState.currentGuess.length != GameState.wordLength) {
      return 'Not enough letters';
    }

    // Validate word
    if (!_validWords.contains(_gameState.currentGuess)) {
      return 'Not in word list';
    }

    // Evaluate the guess
    final tiles = _evaluateGuess(_gameState.currentGuess);

    // Update guesses
    final newGuesses = List<List<TileState>>.from(_gameState.guesses);
    newGuesses[_gameState.currentRow] = tiles;

    // Check if won
    final isWin = _gameState.currentGuess == _gameState.targetWord;
    final newRow = _gameState.currentRow + 1;
    final isLoss = !isWin && newRow >= GameState.maxAttempts;

    GameStatus newStatus = GameStatus.playing;
    if (isWin) {
      newStatus = GameStatus.won;
    } else if (isLoss) {
      newStatus = GameStatus.lost;
    }

    _gameState = _gameState.copyWith(
      guesses: newGuesses,
      currentRow: newRow,
      currentGuess: '',
      status: newStatus,
    );

    notifyListeners();
    return null; // No error
  }

  /// Evaluate a guess and return tile states with arrow directions
  List<TileState> _evaluateGuess(String guess) {
    final tiles = <TileState>[];
    final targetWord = _gameState.targetWord;
    final guessLetters = guess.split('');
    final targetLetters = targetWord.split('');

    // Track which target positions have been matched
    final targetMatched = List<bool>.filled(6, false);
    final guessStatuses = List<LetterStatus?>.filled(6, null);

    // First pass: mark correct letters (green)
    for (int i = 0; i < 6; i++) {
      if (guessLetters[i] == targetLetters[i]) {
        guessStatuses[i] = LetterStatus.correct;
        targetMatched[i] = true;
      }
    }

    // Second pass: mark present letters (yellow)
    for (int i = 0; i < 6; i++) {
      if (guessStatuses[i] == LetterStatus.correct) continue;

      bool found = false;
      for (int j = 0; j < 6; j++) {
        if (!targetMatched[j] && guessLetters[i] == targetLetters[j]) {
          guessStatuses[i] = LetterStatus.present;
          targetMatched[j] = true;
          found = true;
          break;
        }
      }

      if (!found) {
        guessStatuses[i] = LetterStatus.absent;
      }
    }

    // Third pass: calculate arrow directions
    for (int i = 0; i < 6; i++) {
      ArrowDirection arrowDirection = ArrowDirection.none;

      if (guessStatuses[i] == LetterStatus.present) {
        // Yellow letter - find where it should go
        final letter = guessLetters[i];
        for (int j = 0; j < 6; j++) {
          if (targetLetters[j] == letter) {
            arrowDirection = j < i ? ArrowDirection.left : ArrowDirection.right;
            break;
          }
        }
      } else if (guessStatuses[i] == LetterStatus.correct) {
        // Green letter - check if there are duplicates
        final letter = guessLetters[i];
        final positions = <int>[];
        for (int j = 0; j < 6; j++) {
          if (targetLetters[j] == letter) {
            positions.add(j);
          }
        }

        // If letter appears multiple times in target word, show arrow to other occurrence
        if (positions.length > 1) {
          for (var pos in positions) {
            if (pos != i) {
              arrowDirection = pos < i
                  ? ArrowDirection.left
                  : ArrowDirection.right;
              break;
            }
          }
        }
      }

      tiles.add(
        TileState(
          letter: guessLetters[i],
          status: guessStatuses[i]!,
          arrowDirection: arrowDirection,
        ),
      );
    }

    return tiles;
  }

  /// Get the status of a letter based on all previous guesses
  LetterStatus getKeyStatus(String letter) {
    letter = letter.toUpperCase();
    LetterStatus bestStatus = LetterStatus.empty;

    for (int row = 0; row < _gameState.currentRow; row++) {
      for (var tile in _gameState.guesses[row]) {
        if (tile.letter == letter) {
          if (tile.status == LetterStatus.correct) {
            return LetterStatus.correct;
          } else if (tile.status == LetterStatus.present) {
            bestStatus = LetterStatus.present;
          } else if (tile.status == LetterStatus.absent &&
              bestStatus == LetterStatus.empty) {
            bestStatus = LetterStatus.absent;
          }
        }
      }
    }

    return bestStatus;
  }
}
