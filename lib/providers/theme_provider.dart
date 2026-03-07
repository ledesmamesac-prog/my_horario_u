import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeModeKey);
    
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.dark) {
      await prefs.setBool(_themeModeKey, true);
    } else if (mode == ThemeMode.light) {
      await prefs.setBool(_themeModeKey, false);
    } else {
      await prefs.remove(_themeModeKey);
    }
  }

  void toggleTheme() {
    // Si está en sistema, ver el brillo actual no es directo aquí sin BuildContext, 
    // así que lo hacemos binario para la versión básica.
    final esOscuro = _themeMode == ThemeMode.dark;
    setThemeMode(esOscuro ? ThemeMode.light : ThemeMode.dark);
  }
}
