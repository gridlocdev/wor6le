import 'package:flutter/material.dart';
import '../models/tile_state.dart';
import '../models/letter_status.dart';
import '../models/arrow_direction.dart';
import '../widgets/wordle_tile.dart';
import '../utils/constants.dart';

class HelpDialog extends StatelessWidget {
  final bool colorBlindMode;
  final bool darkMode;

  const HelpDialog({
    super.key,
    this.colorBlindMode = false,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.getBackgroundColor(darkMode),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'HOW TO PLAY',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextColorForBackground(darkMode),
                    ),
                  ),
                  Tooltip(
                    message: 'Close',
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColors.getTextColorForBackground(darkMode),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Guess the WOR6LE in 6 tries.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.getTextColorForBackground(darkMode),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '• Each guess must be a valid 6-letter word.\n'
                '• The color of the tiles will change to show how close your guess was.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getTextColorForBackground(darkMode),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Examples',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColorForBackground(darkMode),
                ),
              ),
              const SizedBox(height: 16),
              _buildExample('W is in the word and in the correct spot.', [
                const TileState(letter: 'W', status: LetterStatus.correct),
                const TileState(letter: 'A', status: LetterStatus.empty),
                const TileState(letter: 'L', status: LetterStatus.empty),
                const TileState(letter: 'N', status: LetterStatus.empty),
                const TileState(letter: 'U', status: LetterStatus.empty),
                const TileState(letter: 'T', status: LetterStatus.empty),
              ]),
              const SizedBox(height: 16),
              _buildExample(
                'D is in the word but in the wrong spot. The arrow ← shows it belongs to the left.',
                [
                  const TileState(letter: 'I', status: LetterStatus.empty),
                  const TileState(letter: 'N', status: LetterStatus.empty),
                  const TileState(
                    letter: 'D',
                    status: LetterStatus.present,
                    arrowDirection: ArrowDirection.left,
                  ),
                  const TileState(letter: 'I', status: LetterStatus.empty),
                  const TileState(letter: 'G', status: LetterStatus.empty),
                  const TileState(letter: 'O', status: LetterStatus.empty),
                ],
              ),
              const SizedBox(height: 16),
              _buildExample('U is not in the word in any spot.', [
                const TileState(letter: 'A', status: LetterStatus.empty),
                const TileState(letter: 'R', status: LetterStatus.empty),
                const TileState(letter: 'G', status: LetterStatus.empty),
                const TileState(letter: 'U', status: LetterStatus.absent),
                const TileState(letter: 'E', status: LetterStatus.empty),
                const TileState(letter: 'S', status: LetterStatus.empty),
              ]),
              const SizedBox(height: 16),
              _buildExample(
                'L is correct, but appears twice. The arrow → points to the other L!',
                [
                  const TileState(letter: 'F', status: LetterStatus.empty),
                  const TileState(letter: 'I', status: LetterStatus.empty),
                  const TileState(
                    letter: 'L',
                    status: LetterStatus.correct,
                    arrowDirection: ArrowDirection.right,
                  ),
                  const TileState(letter: 'T', status: LetterStatus.empty),
                  const TileState(letter: 'E', status: LetterStatus.empty),
                  const TileState(letter: 'R', status: LetterStatus.empty),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'A new WOR6LE will be available each day!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColorForBackground(darkMode),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExample(String description, List<TileState> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: tiles
              .map(
                (tile) => Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: WordleTile(
                      tileState: tile,
                      colorBlindMode: colorBlindMode,
                      darkMode: darkMode,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.getTextColorForBackground(darkMode),
          ),
        ),
      ],
    );
  }
}
