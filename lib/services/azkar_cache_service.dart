import 'dart:convert';

import 'package:project_azkar/utils/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/azkar/models/daily_azkar_progress.dart';
import '../pages/azkar/models/saved_zekr_entry.dart';
import 'cache_service.dart';

sealed class AzkarCacheService {
  static SharedPreferencesWithCache get _prefs => CacheService.prefsWithCache;

  static const _lifetimeCountKey = 'azkarCount';

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  static String _dailyKey(DuaTime duaTime) => 'daily_azkar_${duaTime.name}';

  // --- Lifetime Total ---

  static int getLifetimeAzkarCount() => _prefs.getInt(_lifetimeCountKey) ?? 0;

  static Future<void> addToLifetimeAzkarCount(int delta) async {
    if (delta == 0) return;
    final next = getLifetimeAzkarCount() + delta;
    await _prefs.setInt(_lifetimeCountKey, next < 0 ? 0 : next);
  }

  // --- Daily Per-Category Progress ---

  static Future<void> cacheDailyProgress({
    required DuaTime duaTime,
    required List<SavedZekrEntry> entries,
  }) async {
    final payload = jsonEncode({
      'date': _todayKey(),
      'items': entries.map((e) => e.toJson()).toList(),
    });
    await _prefs.setString(_dailyKey(duaTime), payload);
  }

  static DailyAzkarProgress getDailyProgress(DuaTime duaTime, int totalZekr) {
    final raw = _prefs.getString(_dailyKey(duaTime));
    if (raw == null) {
      return DailyAzkarProgress(
        completedZekr: 0,
        totalZekr: totalZekr,
        totalRepsRead: 0,
        entries: const [],
      );
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (decoded['date'] != _todayKey()) {
        _prefs.remove(_dailyKey(duaTime));
        return DailyAzkarProgress(
          completedZekr: 0,
          totalZekr: totalZekr,
          totalRepsRead: 0,
          entries: const [],
        );
      }

      final rawItems = decoded['items'] as List<dynamic>? ?? [];
      final entries = rawItems
          .map((e) => SavedZekrEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      final completed = entries.where((e) => e.isCompleted).length;
      final totalReps = entries.fold<int>(0, (sum, e) => sum + e.readReps);

      return DailyAzkarProgress(
        completedZekr: completed,
        totalZekr: totalZekr,
        totalRepsRead: totalReps,
        entries: entries,
      );
    } catch (_) {
      return DailyAzkarProgress(
        completedZekr: 0,
        totalZekr: totalZekr,
        totalRepsRead: 0,
        entries: const [],
      );
    }
  }
}
