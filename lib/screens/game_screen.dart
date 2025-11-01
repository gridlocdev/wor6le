import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/game_controller.dart';
import '../widgets/game_grid.dart';
import '../widgets/game_keyboard.dart';
import '../dialogs/help_dialog.dart';
import '../dialogs/settings_dialog.dart';
import '../dialogs/stats_dialog.dart';
import '../dialogs/game_over_dialog.dart';
import '../services/storage_service.dart';
import '../models/game_statistics.dart';
import '../models/game_status.dart';
import '../utils/constants.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController _controller;
  final FocusNode _focusNode = FocusNode();
  final StorageService _storage = StorageService();
  GameStatistics _statistics = const GameStatistics();
  bool _colorBlindMode = false;
  bool _darkMode = false;
  bool _shakeRow = false;

  @override
  void initState() {
    super.initState();
    _controller = GameController('FLUTTER');
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    await _controller.loadWords();

    // Load settings
    _colorBlindMode = await _storage.getColorBlindMode();
    _darkMode = await _storage.getDarkMode();

    // Load statistics
    _statistics = await _storage.loadStatistics();

    // Initialize a new game
    _controller.initializeNewGame();

    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.enter) {
      _submitGuess();
    } else if (key == LogicalKeyboardKey.backspace ||
        key == LogicalKeyboardKey.delete) {
      _controller.removeLetter();
    } else if (key.keyLabel.length == 1) {
      final char = key.keyLabel.toUpperCase();
      if (RegExp(r'[A-Z]').hasMatch(char)) {
        _controller.addLetter(char);
      }
    }
  }

  Future<void> _submitGuess() async {
    final error = await _controller.submitGuess();
    if (error != null && mounted) {
      setState(() => _shakeRow = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _shakeRow = false);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          duration: const Duration(milliseconds: 800),
          backgroundColor: Colors.black87,
        ),
      );
    } else if (mounted && _controller.gameState.isGameOver) {
      await _handleGameOver();
    }
  }

  Future<void> _handleGameOver() async {
    final isWin = _controller.gameState.status == GameStatus.won;

    // Update statistics
    await _storage.updateStatisticsAfterGame(
      won: isWin,
      attempts: _controller.gameState.currentRow,
    );

    // Reload statistics
    _statistics = await _storage.loadStatistics();

    _showGameOverDialog();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => GameOverDialog(
        gameState: _controller.gameState,
        statistics: _statistics,
        colorBlindMode: _colorBlindMode,
        darkMode: _darkMode,
        onPlayAgain: () {
          setState(() {
            _controller.initializeNewGame();
          });
        },
        onResetStats: () async {
          await _storage.resetStatistics();
          final newStats = await _storage.loadStatistics();
          setState(() {
            _statistics = newStats;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: AppColors.getBackgroundColor(_darkMode),
        appBar: AppBar(
          backgroundColor: AppColors.getAppBarBackgroundColor(_darkMode),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.refresh,
              color: AppColors.getTextColorForBackground(_darkMode),
            ),
            onPressed: () {
              setState(() {
                _controller.initializeNewGame();
              });
            },
            tooltip: 'New Game',
          ),
          title: Text(
            'WOR6LE',
            style: AppTextStyles.title.copyWith(
              color: AppColors.getTextColorForBackground(_darkMode),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.help_outline,
                color: AppColors.getTextColorForBackground(_darkMode),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => HelpDialog(
                    colorBlindMode: _colorBlindMode,
                    darkMode: _darkMode,
                  ),
                );
              },
              tooltip: 'How to Play',
            ),
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: AppColors.getTextColorForBackground(_darkMode),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => SettingsDialog(
                    colorBlindMode: _colorBlindMode,
                    darkMode: _darkMode,
                    onColorBlindModeChanged: (value) async {
                      setState(() => _colorBlindMode = value);
                      await _storage.setColorBlindMode(value);
                    },
                    onDarkModeChanged: (value) async {
                      setState(() => _darkMode = value);
                      await _storage.setDarkMode(value);
                    },
                  ),
                );
              },
              tooltip: 'Settings',
            ),
            IconButton(
              icon: Icon(
                Icons.bar_chart,
                color: AppColors.getTextColorForBackground(_darkMode),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => StatsDialog(
                    statistics: _statistics,
                    gameState: _controller.gameState,
                    colorBlindMode: _colorBlindMode,
                    darkMode: _darkMode,
                    onReset: () async {
                      await _storage.resetStatistics();
                      final newStats = await _storage.loadStatistics();
                      setState(() {
                        _statistics = newStats;
                      });
                    },
                  ),
                );
              },
              tooltip: 'Statistics',
            ),
          ],
        ),
        body: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return Column(
              children: [
                SizedBox(height: AppSizes.screenPadding),
                Expanded(
                  child: Center(
                    child: GameGrid(
                      gameState: _controller.gameState,
                      shakeCurrentRow: _shakeRow,
                      colorBlindMode: _colorBlindMode,
                      darkMode: _darkMode,
                    ),
                  ),
                ),
                GameKeyboard(
                  controller: _controller,
                  colorBlindMode: _colorBlindMode,
                  darkMode: _darkMode,
                  onInvalidGuess: () {
                    setState(() => _shakeRow = true);
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) setState(() => _shakeRow = false);
                    });
                  },
                ),
                SizedBox(height: AppSizes.screenPadding),
              ],
            );
          },
        ),
      ),
    );
  }
}
