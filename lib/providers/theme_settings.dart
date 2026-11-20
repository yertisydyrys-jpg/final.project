import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettings extends ChangeNotifier {
  ThemeSettings(this._prefs, bool initialDarkMode)
    : _isDarkMode = initialDarkMode;

  final SharedPreferences _prefs;
  bool _isDarkMode;

  bool get isDarkMode => _isDarkMode;

  Future<void> setDarkMode(bool value) async {
    final saved = await _prefs.setBool('app_theme_dark_mode', value);
    if (!saved) {
      throw StateError('Could not save the theme preference.');
    }

    _isDarkMode = value;
    notifyListeners();
  }
}
