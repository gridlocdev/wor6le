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
import '../models/theme_mode.dart';
import '../utils/constants.dart';

class GameScreen extends StatefulWidget {
  final bool? initialDarkMode;

  const GameScreen({super.key, this.initialDarkMode});

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
  AppThemeMode _themeMode = AppThemeMode.system;
  bool _shakeRow = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = GameController('FLUTTER');
    // Use the initialDarkMode passed from main to avoid a background
    // color flash while SharedPreferences loads.
    if (widget.initialDarkMode != null) {
      _darkMode = widget.initialDarkMode!;
    }
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    // Get system brightness using WidgetsBinding instead of MediaQuery
    // to avoid context issues during initState
    final systemBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    // Load settings first
    _colorBlindMode = await _storage.getColorBlindMode();
    final themeModeString = await _storage.getThemeMode();
    _themeMode = AppThemeMode.fromString(themeModeString);

    // Determine dark mode based on theme mode
    _darkMode = _resolveDarkMode(_themeMode, systemBrightness);

    // Load statistics
    _statistics = await _storage.loadStatistics();

    // Load words and initialize game
    await _controller.loadWords();
    _controller.initializeNewGame();

    // Mark as initialized
    setState(() {
      _isInitialized = true;
    });
  }

  bool _resolveDarkMode(AppThemeMode themeMode, Brightness systemBrightness) {
    switch (themeMode) {
      case AppThemeMode.system:
        return systemBrightness == Brightness.dark;
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
    }
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

    // Use addPostFrameCallback to ensure the dialog shows after the frame
    // is rendered, which is more reliable on iOS Safari
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showGameOverDialog();
        }
      });
    }
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
          leading: Visibility(
            visible: _isInitialized,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: IconButton(
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
          ),
          title: Text(
            'WOR6LE',
            style: AppTextStyles.title.copyWith(
              color: AppColors.getTextColorForBackground(_darkMode),
            ),
          ),
          centerTitle: true,
          actions: [
            Visibility(
              visible: _isInitialized,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: IconButton(
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
            ),
            Visibility(
              visible: _isInitialized,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: IconButton(
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
                      themeMode: _themeMode,
                      onColorBlindModeChanged: (value) async {
                        setState(() => _colorBlindMode = value);
                        await _storage.setColorBlindMode(value);
                      },
                      onThemeModeChanged: (themeMode) async {
                        final systemBrightness = WidgetsBinding
                            .instance
                            .platformDispatcher
                            .platformBrightness;
                        final newDarkMode = _resolveDarkMode(
                          themeMode,
                          systemBrightness,
                        );

                        setState(() {
                          _themeMode = themeMode;
                          _darkMode = newDarkMode;
                        });

                        await _storage.setThemeMode(
                          themeMode.toStorageString(),
                        );

                        // Update native window background color
                        try {
                          const platform = MethodChannel('com.wor6le/window');
                          await platform.invokeMethod(
                            'setWindowBackgroundColor',
                            {'isDark': newDarkMode},
                          );
                        } catch (e) {
                          // Platform channel not available
                        }
                      },
                      onResetSettings: () async {
                        // Reset to default values
                        const defaultThemeMode = AppThemeMode.system;
                        const defaultColorBlindMode = false;

                        await _storage.setColorBlindMode(defaultColorBlindMode);
                        await _storage.setThemeMode(
                          defaultThemeMode.toStorageString(),
                        );

                        final systemBrightness = WidgetsBinding
                            .instance
                            .platformDispatcher
                            .platformBrightness;
                        final newDarkMode = _resolveDarkMode(
                          defaultThemeMode,
                          systemBrightness,
                        );

                        setState(() {
                          _colorBlindMode = defaultColorBlindMode;
                          _themeMode = defaultThemeMode;
                          _darkMode = newDarkMode;
                        });

                        // Update native window background color
                        try {
                          const platform = MethodChannel('com.wor6le/window');
                          await platform.invokeMethod(
                            'setWindowBackgroundColor',
                            {'isDark': newDarkMode},
                          );
                        } catch (e) {
                          // Platform channel not available
                        }
                      },
                    ),
                  );
                },
                tooltip: 'Settings',
              ),
            ),
            Visibility(
              visible: _isInitialized,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: IconButton(
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
            ),
          ],
        ),
        body: !_isInitialized
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.getTextColorForBackground(_darkMode),
                ),
              )
            : ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  // Detect if device supports touch
                  final platform = Theme.of(context).platform;
                  final isTouchDevice =
                      platform == TargetPlatform.iOS ||
                      platform == TargetPlatform.android ||
                      platform == TargetPlatform.fuchsia;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Flexible(
                        flex: 4,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isTouchDevice ? double.infinity : 500,
                              maxHeight: isTouchDevice ? double.infinity : 420,
                            ),
                            child: GameGrid(
                              gameState: _controller.gameState,
                              shakeCurrentRow: _shakeRow,
                              colorBlindMode: _colorBlindMode,
                              darkMode: _darkMode,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isTouchDevice ? double.infinity : 650,
                            ),
                            child: GameKeyboard(
                              controller: _controller,
                              colorBlindMode: _colorBlindMode,
                              darkMode: _darkMode,
                              onInvalidGuess: () {
                                setState(() => _shakeRow = true);
                                Future.delayed(
                                  const Duration(milliseconds: 500),
                                  () {
                                    if (mounted) {
                                      setState(() => _shakeRow = false);
                                    }
                                  },
                                );
                              },
                              onGameOver: () {
                                _handleGameOver();
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
