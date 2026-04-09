import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _speechRateKey = 'speech_rate';
  static const _ignoreSuperKey = 'ignore_super';
  static const _ignoreSubKey = 'ignore_sub';
  static const _volume   = 'volume';

  Future<void> saveSettings(
      double rate, 
      bool ignoreSuper, 
      bool ignoreSub, 
      double volume, 
      String voice,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_speechRateKey, rate);
    await prefs.setBool(_ignoreSuperKey, ignoreSuper);
    await prefs.setBool(_ignoreSubKey, ignoreSub);
    await prefs.setDouble(_volume, volume);
    await prefs.setString('voice', voice);
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