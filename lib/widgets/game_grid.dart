import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/tile_state.dart';
import '../utils/constants.dart';
import 'wordle_tile.dart';
import 'shake_widget.dart';

class GameGrid extends StatefulWidget {
  final GameState gameState;
  final bool shakeCurrentRow;
  final bool colorBlindMode;
  final bool darkMode;

  const GameGrid({
    super.key,
    required this.gameState,
    this.shakeCurrentRow = false,
    this.colorBlindMode = false,
    this.darkMode = false,
  });

  @override
  State<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid> {
  int _lastCompletedRow = -1;

  @override
  void didUpdateWidget(GameGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gameState.currentRow > oldWidget.gameState.currentRow) {
      _lastCompletedRow = oldWidget.gameState.currentRow;
    }
  }

  List<TileState> _getCurrentRowTiles() {
    final currentGuess = widget.gameState.currentGuess;
    final tiles = <TileState>[];

    for (int i = 0; i < GameState.wordLength; i++) {
      if (i < currentGuess.length) {
        tiles.add(
          TileState(
            letter: currentGuess[i],
            status:
                widget.gameState.guesses[widget.gameState.currentRow][i].status,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the maximum tile size that fits within the available space
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        // Calculate max tile size based on width
        final totalHorizontalGaps =
            (GameState.wordLength - 1) * AppSizes.tileGap;
        final maxTileWidthFromWidth =
            (availableWidth - totalHorizontalGaps - 40) / GameState.wordLength;

        // Calculate max tile size based on height
        final totalVerticalGaps =
            (GameState.maxAttempts - 1) * AppSizes.gridRowGap;
        final maxTileHeightFromHeight =
            (availableHeight - totalVerticalGaps - 20) / GameState.maxAttempts;

        // Use the smaller of the two to maintain square tiles
        // Allow expansion to fill larger screens while maintaining padding
        final tileSize =
            (maxTileWidthFromWidth < maxTileHeightFromHeight
                    ? maxTileWidthFromWidth
                    : maxTileHeightFromHeight)
                .clamp(AppSizes.tileSizeMin, AppSizes.tileSizeMax);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(GameState.maxAttempts, (rowIndex) {
            final isCurrentRow =
                rowIndex == widget.gameState.currentRow &&
                !widget.gameState.isGameOver;
            final shouldAnimate = rowIndex == _lastCompletedRow;

            List<TileState> rowTiles;
            if (rowIndex < widget.gameState.currentRow) {
              // Past guesses - show evaluated tiles
              rowTiles = widget.gameState.guesses[rowIndex];
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
              padding: EdgeInsets.symmetric(vertical: AppSizes.gridRowGap / 2),
              child: ShakeWidget(
                shake: isCurrentRow && widget.shakeCurrentRow,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(GameState.wordLength, (colIndex) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.tileGap / 2,
                      ),
                      child: SizedBox(
                        width: tileSize,
                        height: tileSize,
                        child: WordleTile(
                          key: ValueKey(
                            '$rowIndex-$colIndex-${rowTiles[colIndex].letter}',
                          ),
                          tileState: rowTiles[colIndex],
                          isCurrentRow: isCurrentRow,
                          index: colIndex,
                          animate: shouldAnimate,
                          colorBlindMode: widget.colorBlindMode,
                          darkMode: widget.darkMode,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
