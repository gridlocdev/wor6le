import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
              _buildExample(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'W',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: ' is in the word and in the correct spot.',
                    ),
                  ],
                ),
                [
                  const TileState(letter: 'W', status: LetterStatus.correct),
                  const TileState(letter: 'A', status: LetterStatus.empty),
                  const TileState(letter: 'L', status: LetterStatus.empty),
                  const TileState(letter: 'N', status: LetterStatus.empty),
                  const TileState(letter: 'U', status: LetterStatus.empty),
                  const TileState(letter: 'T', status: LetterStatus.empty),
                ],
              ),
              const SizedBox(height: 16),
              _buildExample(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'D',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: ' is in the word but in the wrong spot. The arrow ',
                    ),
                    const TextSpan(
                      text: '←',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' shows it belongs to the left.'),
                  ],
                ),
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
              _buildExample(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'U',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' is not in the word in any spot.'),
                  ],
                ),
                [
                  const TileState(letter: 'A', status: LetterStatus.empty),
                  const TileState(letter: 'R', status: LetterStatus.empty),
                  const TileState(letter: 'G', status: LetterStatus.empty),
                  const TileState(letter: 'U', status: LetterStatus.absent),
                  const TileState(letter: 'E', status: LetterStatus.empty),
                  const TileState(letter: 'S', status: LetterStatus.empty),
                ],
              ),
              const SizedBox(height: 16),
              _buildExample(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'L',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: ' is correct, but appears twice. The arrow ',
                    ),
                    const TextSpan(
                      text: '→',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' points to the other '),
                    const TextSpan(
                      text: 'L',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '!'),
                  ],
                ),
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
              Divider(),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.normal,
                    color: AppColors.getTextColorForBackground(darkMode),
                  ),
                  children: [
                    const TextSpan(
                      text:
                          "Disclaimer: You might have been able to tell, but this isn't the official Wordle game. It is a fan-made version I've created for fun.\n\n",
                    ),
                    const TextSpan(
                      text:
                          'The original Wordle game owned by the New York Times can be found here: ',
                    ),
                    TextSpan(
                      text: 'https://www.nytimes.com/games/wordle/index.html',
                      style: TextStyle(
                        color: darkMode ? Colors.lightBlue : Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          final url = Uri.parse(
                            'https://www.nytimes.com/games/wordle/index.html',
                          );
                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExample(InlineSpan description, List<TileState> tiles) {
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
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextColorForBackground(darkMode),
            ),
            children: [description],
          ),
        ),
      ],
    );
  }
}
