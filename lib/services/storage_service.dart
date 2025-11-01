import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_statistics.dart';

class StorageService {
  static const String _statsKey = 'game_statistics';
  static const String _lastPlayedKey = 'last_played_date';
  static const String _colorBlindModeKey = 'color_blind_mode';
  static const String _themeModeKey = 'theme_mode';

  Future<GameStatistics> loadStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsKey);

      if (statsJson != null) {
        debugPrint('Loading statistics: $statsJson');
        final Map<String, dynamic> decoded = jsonDecode(statsJson);
        final stats = GameStatistics.fromJson(decoded);
        debugPrint(
          'Loaded stats - Games: ${stats.gamesPlayed}, Wins: ${stats.gamesWon}, Streak: ${stats.currentStreak}/${stats.maxStreak}',
        );
        return stats;
      }
    } catch (e) {
      debugPrint('Error loading statistics: $e');
      // Return default statistics on error
    }

    return const GameStatistics();
  }

  Future<void> saveStatistics(GameStatistics statistics) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = jsonEncode(statistics.toJson());
      debugPrint('Saving statistics: $statsJson');
      await prefs.setString(_statsKey, statsJson);
      debugPrint('Statistics saved successfully');
    } catch (e) {
      debugPrint('Error saving statistics: $e');
      // Handle error silently
    }
  }

  Future<String?> getLastPlayedDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastPlayedKey);
    } catch (e) {
      return null;
    }
  }

  Future<void> setLastPlayedDate(String date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastPlayedKey, date);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<bool> getColorBlindMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_colorBlindModeKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> setColorBlindMode(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_colorBlindModeKey, value);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get the theme mode preference (system, light, or dark)
  /// Returns 'system' if no preference is set
  Future<String> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Check new key first
      if (prefs.containsKey(_themeModeKey)) {
        return prefs.getString(_themeModeKey) ?? 'system';
      }
      return 'system';
    } catch (e) {
      return 'system';
    }
  }

  /// Set the theme mode preference
  Future<void> setThemeMode(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, value);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> updateStatisticsAfterGame({
    required bool won,
    required int attempts,
  }) async {
    debugPrint('=== Updating statistics after game ===');
    debugPrint('Won: $won, Attempts: $attempts');

    final stats = await loadStatistics();
    debugPrint(
      'Current stats before update - Games: ${stats.gamesPlayed}, Wins: ${stats.gamesWon}, Streak: ${stats.currentStreak}/${stats.maxStreak}',
    );

    // Increment games played counter
    final newGamesPlayed = stats.gamesPlayed + 1;

    // Increment wins counter if game was won
    final newGamesWon = won ? stats.gamesWon + 1 : stats.gamesWon;

    // Streak logic based on consecutive wins:
    // - If won: increment current streak by 1
    // - If lost: reset current streak to 0
    final newCurrentStreak = won ? stats.currentStreak + 1 : 0;

    // Update max streak if current streak exceeds it
    final newMaxStreak = newCurrentStreak > stats.maxStreak
        ? newCurrentStreak
        : stats.maxStreak;

    // Update guess distribution (only for wins)
    final newDistribution = Map<int, int>.from(stats.guessDistribution);
    if (won) {
      newDistribution[attempts] = (newDistribution[attempts] ?? 0) + 1;
    }

    final newStats = GameStatistics(
      gamesPlayed: newGamesPlayed,
      gamesWon: newGamesWon,
      currentStreak: newCurrentStreak,
      maxStreak: newMaxStreak,
      guessDistribution: newDistribution,
    );

    debugPrint(
      'New stats after update - Games: ${newStats.gamesPlayed}, Wins: ${newStats.gamesWon}, Streak: ${newStats.currentStreak}/${newStats.maxStreak}',
    );
    await saveStatistics(newStats);
    debugPrint('=== Statistics update complete ===');
  }

  Future<void> resetStatistics() async {
    await saveStatistics(const GameStatistics());
  }
}
