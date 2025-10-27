import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/game_controller.dart';
import '../widgets/game_grid.dart';
import '../widgets/game_keyboard.dart';
import '../dialogs/help_dialog.dart';
import '../dialogs/settings_dialog.dart';
import '../dialogs/stats_dialog.dart';
import '../services/storage_service.dart';
import '../models/game_statistics.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

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

    // Check if new day
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastPlayed = await _storage.getLastPlayedDate();

    if (lastPlayed != today) {
      _controller.initializeNewGame();
      await _storage.setLastPlayedDate(today);
    } else {
      _controller.initializeNewGame();
    }

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
    final isWin = _controller.gameState.status.toString().contains('won');

    // Update statistics
    final lastPlayed = await _storage.getLastPlayedDate();
    final continuedStreak =
        lastPlayed != null &&
        _isSameDay(
          DateTime.parse(lastPlayed).add(const Duration(days: 1)),
          DateTime.now(),
        );

    await _storage.updateStatisticsAfterGame(
      won: isWin,
      attempts: _controller.gameState.currentRow,
      continuedStreak: continuedStreak,
    );

    // Reload statistics
    _statistics = await _storage.loadStatistics();

    _showGameOverDialog();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showGameOverDialog() {
    final isWin = _controller.gameState.status.toString().contains('won');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isWin ? 'Congratulations!' : 'Game Over'),
        content: Text(
          isWin
              ? 'You won in ${_controller.gameState.currentRow} ${_controller.gameState.currentRow == 1 ? 'guess' : 'guesses'}!'
              : 'The word was: ${_controller.gameState.targetWord}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) => StatsDialog(
                  statistics: _statistics,
                  gameState: _controller.gameState,
                ),
              );
            },
            child: const Text('View Stats'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _controller.initializeNewGame();
              });
            },
            child: const Text('Play Again'),
          ),
        ],
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.appBarBackground,
          elevation: 0,
          title: const Text('WOR6LE', style: AppTextStyles.title),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline, color: AppColors.textDark),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const HelpDialog(),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.settings_outlined, color: AppColors.textDark),
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
            ),
            IconButton(
              icon: Icon(Icons.bar_chart, color: AppColors.textDark),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => StatsDialog(
                    statistics: _statistics,
                    gameState: _controller.gameState,
                  ),
                );
              },
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
                    ),
                  ),
                ),
                GameKeyboard(
                  controller: _controller,
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
