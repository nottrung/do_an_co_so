import 'package:flutter/material.dart';
import 'app_themes.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider() : _themeData = AppThemes.lightTheme;

  ThemeData get themeData => _themeData;

  void setTheme(ThemeData theme) {
    _themeData = theme;
    notifyListeners();
  }
}
