import 'package:flutter/material.dart';

/// Single source of truth for the application's theme mode.
///
/// The controller is intentionally dependency-free so the project does not
/// need another package just to share theme state between screens.
class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._internal();

  ThemeController({ThemeMode initialMode = ThemeMode.dark})
      : _themeMode = initialMode;

  ThemeController._internal() : _themeMode = ThemeMode.dark;

  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggle() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();
  }
}
