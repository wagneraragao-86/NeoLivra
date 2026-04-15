import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _speechRateKey = 'speech_rate';
  static const _ignoreSuperKey = 'ignore_super';
  static const _ignoreSubKey = 'ignore_sub';
  static const _volume   = 'volume';
  static const _themeKey = 'is_dark';
  static const _voiceKey = 'voice';

  Future<void> saveSettings(
      double rate, 
      bool ignoreSuper, 
      bool ignoreSub, 
      double volume, 
      String voice,
      bool isDark,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_speechRateKey, rate);
    await prefs.setBool(_ignoreSuperKey, ignoreSuper);
    await prefs.setBool(_ignoreSubKey, ignoreSub);
    await prefs.setDouble(_volume, volume);
    await prefs.setString(_voiceKey, voice);
    await prefs.setBool(_themeKey, isDark);
   }

  Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark', isDark);
  }

  Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_dark') ?? true;
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "rate": prefs.getDouble(_speechRateKey) ?? 0.5,
      "ignoreSuper": prefs.getBool(_ignoreSuperKey) ?? true,
      "ignoreSub": prefs.getBool(_ignoreSubKey) ?? true,
      "volume": prefs.getDouble(_volume) ?? 0.5,
      "voice": prefs.getString('voice')  ??  'default',
    };
  }
}