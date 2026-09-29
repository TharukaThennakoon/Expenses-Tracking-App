import 'package:flutter/material.dart';

/// App-wide light/dark choice. [MaterialApp] listens to this.
class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  // TODO: persist the choice so it survives an app restart.
  void setDark(bool dark) {
    final mode = dark ? ThemeMode.dark : ThemeMode.light;
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
  }
}
