import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/tile_state.dart';
import 'wordle_tile.dart';

class GameGrid extends StatelessWidget {
  final GameState gameState;

  const GameGrid({super.key, required this.gameState});

  List<TileState> _getCurrentRowTiles() {
    final currentGuess = gameState.currentGuess;
    final tiles = <TileState>[];

    for (int i = 0; i < GameState.wordLength; i++) {
      if (i < currentGuess.length) {
        tiles.add(
          TileState(
            letter: currentGuess[i],
            status: gameState.guesses[gameState.currentRow][i].status,
          ),
        );
      } else {
        tiles.add(TileState.empty());
      }
    }

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(GameState.maxAttempts, (rowIndex) {
        final isCurrentRow =
            rowIndex == gameState.currentRow && !gameState.isGameOver;

        List<TileState> rowTiles;
        if (rowIndex < gameState.currentRow) {
          // Past guesses - show evaluated tiles
          rowTiles = gameState.guesses[rowIndex];
        } else if (isCurrentRow) {
          // Current row being typed
          rowTiles = _getCurrentRowTiles();
        } else {
          // Future rows - empty
          rowTiles = List.generate(
            GameState.wordLength,
            (_) => TileState.empty(),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(GameState.wordLength, (colIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: WordleTile(
                  tileState: rowTiles[colIndex],
                  isCurrentRow: isCurrentRow,
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
