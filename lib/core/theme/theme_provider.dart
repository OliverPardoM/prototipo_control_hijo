import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = "theme_mode";

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedTheme,
        orElse: () => ThemeMode.system,
      );
    }

    notifyListeners();
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setDarkMode();
    } else if (_themeMode == ThemeMode.dark) {
      setLightMode();
    } else {
      final isSystemDark =
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
      _themeMode = isSystemDark ? ThemeMode.light : ThemeMode.dark;
      _saveTheme(_themeMode);
      notifyListeners();
    }
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveTheme(mode);
    notifyListeners();
  }

  void setLightMode() {
    _themeMode = ThemeMode.light;
    _saveTheme(_themeMode);
    notifyListeners();
  }

  void setDarkMode() {
    _themeMode = ThemeMode.dark;
    _saveTheme(_themeMode);
    notifyListeners();
  }

  void setSystemMode() {
    _themeMode = ThemeMode.system;
    _saveTheme(_themeMode);
    notifyListeners();
  }
}
