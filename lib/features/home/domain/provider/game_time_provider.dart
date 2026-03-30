import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/game_time_service.dart';

class GameTimeProvider extends ChangeNotifier {
  int _minutesPlayedToday = 0;
  bool _isLoading = true;
  bool _isBlocked = false;

  static const int dailyLimit = 2;

  int get minutesPlayedToday => _minutesPlayedToday;
  bool get isLoading => _isLoading;
  bool get isBlocked => _isBlocked;

  GameTimeProvider() {
    loadTodayMinutes();
  }

  Future<void> loadTodayMinutes() async {
    _isLoading = true;
    notifyListeners();

    _minutesPlayedToday = await GameTimeService.getTodayMinutes();

    _evaluateBlock();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> startGameSession(String gameId) async {
    await GameTimeService.startGameSession(gameId);
  }

  Future<void> endGameSession(String gameId) async {
    await GameTimeService.endGameSession(gameId);
    await loadTodayMinutes();
  }

  Future<void> parentUnlock() async {
    await resetCounter();
    _isBlocked = false;
    notifyListeners();
  }

  void _evaluateBlock() {
    _isBlocked = _minutesPlayedToday >= dailyLimit;
  }

  Future<void> setTestMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_minutes', minutes);
    final today = DateTime.now();
    await prefs.setInt('last_reset_date', today.millisecondsSinceEpoch);
    await loadTodayMinutes();
  }

  Future<void> resetCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_minutes', 0);
    await loadTodayMinutes();
  }
}
