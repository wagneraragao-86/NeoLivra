import 'package:flutter/material.dart';
import 'package:neolivra/main.dart';
import '../config/settings_service.dart';

class ThemeController extends ChangeNotifier {
  bool _isDark = true;
  final service = SettingsService();

  bool get isDark => _isDark;

  ThemeMode get themeMode =>
    _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme(bool value) async {
    print("Trocando o tema: $value");
    _isDark = value;
    await service.saveTheme(value);
    notifyListeners();
  }

  void setTheme(bool value) {
    _isDark = value;
    notifyListeners();
  }
}