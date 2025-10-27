import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_statistics.dart';

class StorageService {
  static const String _statsKey = 'game_statistics';
  static const String _lastPlayedKey = 'last_played_date';
  static const String _colorBlindModeKey = 'color_blind_mode';
  static const String _darkModeKey = 'dark_mode';

  Future<GameStatistics> loadStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsKey);
      
      if (statsJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(statsJson);
        return GameStatistics.fromJson(decoded);
      }
    } catch (e) {
      // Return default statistics on error
    }
    
    return const GameStatistics();
  }

  Future<void> saveStatistics(GameStatistics statistics) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = jsonEncode(statistics.toJson());
      await prefs.setString(_statsKey, statsJson);
    } catch (e) {
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

  Future<bool> getDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_darkModeKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> setDarkMode(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, value);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> updateStatisticsAfterGame({
    required bool won,
    required int attempts,
    required bool continuedStreak,
  }) async {
    final stats = await loadStatistics();
    
    final newGamesPlayed = stats.gamesPlayed + 1;
    final newGamesWon = won ? stats.gamesWon + 1 : stats.gamesWon;
    final newCurrentStreak = continuedStreak
        ? (won ? stats.currentStreak + 1 : 0)
        : 0;
    final newMaxStreak = newCurrentStreak > stats.maxStreak
        ? newCurrentStreak
        : stats.maxStreak;
    
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
    
    await saveStatistics(newStats);
  }
}
