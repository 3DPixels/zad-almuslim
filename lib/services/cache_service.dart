import 'package:shared_preferences/shared_preferences.dart';

sealed class CacheService {
  static late SharedPreferencesWithCache prefsWithCache;

  static Future<void> init() async {
    prefsWithCache = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
  }

  static Future<void> clear() async {
    await prefsWithCache.clear();
  }

  // static Future<void> cacheAzkarCount(int count) async {
  //   await prefsWithCache.setInt('azkarCount', count);
  // }

  // static int getAzkarCount() {
  //   final count = prefsWithCache.getInt('azkarCount');
  //   return count ?? 0;
  // }

  static Future<void> cacheLocation(
    double lat,
    double lng,
    String city,
    String country,
  ) async {
    await prefsWithCache.setDouble('user_lat', lat);
    await prefsWithCache.setDouble('user_lng', lng);
    await prefsWithCache.setString('user_city', city);
    await prefsWithCache.setString('user_country', country);
  }

  static Map<String, dynamic>? getCachedLocation() {
    final lat = prefsWithCache.getDouble('user_lat');
    final lng = prefsWithCache.getDouble('user_lng');
    final city = prefsWithCache.getString('user_city');
    final country = prefsWithCache.getString('user_country');

    if (lat != null && lng != null && city != null && country != null) {
      return {'lat': lat, 'lng': lng, 'city': city, 'country': country};
    }
    return null;
  }

  // Notifications Toggles
  static Future<void> cachePrayerToggle(bool val) async =>
      await prefsWithCache.setBool('toggle_prayers', val);
  static bool getPrayerToggle() =>
      prefsWithCache.getBool('toggle_prayers') ?? false;

  static Future<void> cacheDailyAzkarToggle(bool val) async =>
      await prefsWithCache.setBool('toggle_daily', val);
  static bool getDailyAzkarToggle() =>
      prefsWithCache.getBool('toggle_daily') ?? false;

  static Future<void> cacheMorningNightAzkarToggle(bool val) async =>
      await prefsWithCache.setBool('toggle_solar', val);
  static bool getMorningNightAzkarToggle() =>
      prefsWithCache.getBool('toggle_solar') ?? false;

  // Notification Scheduler Optimization
  static Future<void> cacheLastScheduledDate(String isoDate) async =>
      await prefsWithCache.setString('last_scheduled_date', isoDate);
  static String? getLastScheduledDate() =>
      prefsWithCache.getString('last_scheduled_date');

  static Future<void> cacheScheduledCoordinates(double lat, double lng) async {
    await prefsWithCache.setDouble('sched_lat', lat);
    await prefsWithCache.setDouble('sched_lng', lng);
  }

  static ({double lat, double lng})? getScheduledCoordinates() {
    final lat = prefsWithCache.getDouble('sched_lat');
    final lng = prefsWithCache.getDouble('sched_lng');
    if (lat != null && lng != null) {
      return (lat: lat, lng: lng);
    }
    return null;
  }

  static Future<void> clearScheduleMeta() async {
    await prefsWithCache.remove('last_scheduled_date');
    await prefsWithCache.remove('sched_lat');
    await prefsWithCache.remove('sched_lng');
  }
}
