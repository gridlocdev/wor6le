import 'letter_status.dart';
import 'arrow_direction.dart';

/// Represents the state of a single tile in the game grid
class TileState {
  final String letter;
  final LetterStatus status;
  final ArrowDirection arrowDirection;

  const TileState({
    required this.letter,
    required this.status,
    this.arrowDirection = ArrowDirection.none,
  });

  TileState copyWith({
    String? letter,
    LetterStatus? status,
    ArrowDirection? arrowDirection,
  }) {
    return TileState(
      letter: letter ?? this.letter,
      status: status ?? this.status,
      arrowDirection: arrowDirection ?? this.arrowDirection,
    );
  }

  static TileState empty() {
    return const TileState(
      letter: '',
      status: LetterStatus.empty,
      arrowDirection: ArrowDirection.none,
    );
  }
}
