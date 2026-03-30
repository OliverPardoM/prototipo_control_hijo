// lib/features/home/domain/services/game_time_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GameTimeService {
  static const String _dailyMinutesKey = 'daily_minutes';
  static const String _lastResetDateKey = 'last_reset_date';
  static const String _activeSessionKey =
      'active_game_session'; // Solo una sesión activa

  // Registrar inicio de sesión
  static Future<void> startGameSession(String gameId) async {
    final prefs = await SharedPreferences.getInstance();

    // Verificar si ya hay una sesión activa
    final existingSession = prefs.getString(_activeSessionKey);
    if (existingSession != null) {
      await endGameSession(gameId);
    }

    final session = {
      'gameId': gameId,
      'startTime': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_activeSessionKey, jsonEncode(session));
  }

  // Registrar fin de sesión
  static Future<void> endGameSession(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString(_activeSessionKey);

    if (sessionJson != null) {
      final session = jsonDecode(sessionJson);
      final startTime = DateTime.parse(session['startTime']);
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      final minutesPlayed = duration.inMinutes;

      // Solo contar si jugó al menos 10 segundos (para evitar clicks accidentales)
      if (duration.inSeconds >= 10) {
        final minutesToAdd = minutesPlayed > 0 ? minutesPlayed : 1;
        await _updateDailyTime(minutesToAdd);
      } else {}

      // Limpiar sesión activa
      await prefs.remove(_activeSessionKey);
    } else {}
  }

  // Actualizar tiempo diario
  static Future<void> _updateDailyTime(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastReset = await _getLastResetDate();

    // Verificar si es un nuevo día
    if (lastReset == null || !_isSameDay(lastReset, today)) {
      await prefs.setInt(_dailyMinutesKey, minutes);
      await _setLastResetDate(today);
    } else {
      final currentMinutes = prefs.getInt(_dailyMinutesKey) ?? 0;
      final newMinutes = currentMinutes + minutes;
      await prefs.setInt(_dailyMinutesKey, newMinutes);
    }
  }

  // Obtener minutos jugados hoy
  static Future<int> getTodayMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastReset = await _getLastResetDate();

    // Si es nuevo día, reiniciar
    if (lastReset == null || !_isSameDay(lastReset, today)) {
      await prefs.setInt(_dailyMinutesKey, 0);
      await _setLastResetDate(today);
      return 0;
    }

    final minutes = prefs.getInt(_dailyMinutesKey) ?? 0;
    return minutes;
  }

  // Helper: Obtener última fecha de reinicio
  static Future<DateTime?> _getLastResetDate() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastResetDateKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  // Helper: Guardar fecha de reinicio
  static Future<void> _setLastResetDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastResetDateKey, date.millisecondsSinceEpoch);
  }

  // Helper: Verificar si es el mismo día
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Método para testing: limpiar datos
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dailyMinutesKey);
    await prefs.remove(_lastResetDateKey);
    await prefs.remove(_activeSessionKey);
  }
}
