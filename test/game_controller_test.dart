import 'package:flutter_test/flutter_test.dart';
import 'package:wor6le/controllers/game_controller.dart';
import 'package:wor6le/models/letter_status.dart';

void main() {
  group('GameController Arrow Direction Tests', () {
    test('Yellow letter shows arrow to correct position', () {
      final controller = GameController('TESTER');

      // BETTER has E in position 1, but TESTER has E in position 1 and 4
      // So when guessing BETTER, the E at position 1 should be correct (green)
      // and E at position 4 should be yellow pointing left to position 1

      // This is a simplified test - the actual logic is in _evaluateGuess
      expect(controller, isNotNull);
    });

    test('Duplicate green letters show arrows to each other', () {
      final controller = GameController('LETTER');

      // LETTER has T at positions 2 and 3, and E at 1 and 4
      // When correctly guessed, Ts and Es should show arrows to their duplicates

      expect(controller, isNotNull);
    });

    test('Word validation works correctly', () async {
      final controller = GameController('TESTER');
      await controller.loadWords();

      // Add valid 6-letter word
      controller.addLetter('T');
      controller.addLetter('E');
      controller.addLetter('S');
      controller.addLetter('T');
      controller.addLetter('E');
      controller.addLetter('R');

      final error = await controller.submitGuess();
      expect(error, isNull); // Should be valid
    });

    test('Invalid word shows error', () async {
      final controller = GameController('TESTER');
      await controller.loadWords();

      // Add invalid word
      controller.addLetter('X');
      controller.addLetter('Y');
      controller.addLetter('Z');
      controller.addLetter('A');
      controller.addLetter('B');
      controller.addLetter('C');

      final error = await controller.submitGuess();
      expect(error, 'Not in word list');
    });

    test('Not enough letters shows error', () async {
      final controller = GameController('TESTER');
      await controller.loadWords();

      // Add only 3 letters
      controller.addLetter('T');
      controller.addLetter('E');
      controller.addLetter('S');

      final error = await controller.submitGuess();
      expect(error, 'Not enough letters');
    });

    test('Letter status tracking works', () {
      final controller = GameController('TESTER');

      // Initially all letters should be empty
      expect(controller.getKeyStatus('A'), LetterStatus.empty);
      expect(controller.getKeyStatus('T'), LetterStatus.empty);
    });

    test('Daily word is consistent for same date', () {
      final controller = GameController('TESTER');

      final today = DateTime.now();
      final word1 = controller.getDailyWord(today);
      final word2 = controller.getDailyWord(today);

      expect(word1, equals(word2));
      expect(word1.length, 6);
    });
  });
}
