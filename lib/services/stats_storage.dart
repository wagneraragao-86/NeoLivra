import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading_stats.dart';
import '../services/firestore_service.dart';

class StatsStorage {
  static const _key = "reading_stats";

  final firestore = FirestoreService();

  Future<ReadingStats> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    ReadingStats localStats;

    if (jsonString == null) {
      localStats = ReadingStats();
    } else {
      localStats = ReadingStats.fromJson(json.decode(jsonString));
    }

    // tenta buscar da nuvem
    try {
      //final cloudStats = await firestore.carregarStats();
      //return cloudStats;
    } catch (_) {
    }
      return localStats;
    }
  

  Future<void> save(ReadingStats stats) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_key, json.encode(stats.toJson()));

    // salva na nuvem também
    try {
      //await firestore.salvarStats(stats);
    } catch (_) {
      // ignora erro de internet
    }
  }
}