import 'adhan_service.dart';
import 'cache_service.dart';
import 'notification_service.dart';

class NotificationScheduler {
  final AdhanService _adhanService;
  final NotificationService _notificationService;

  NotificationScheduler(this._adhanService, this._notificationService);

  Future<void> cancelAllPrayers() async {
    await _notificationService.cancelRange(1000, 1045);
    await CacheService.clearScheduleMeta();
  }

  Future<void> cancelMorningNightAzkar() async {
    await _notificationService.cancelRange(2000, 2014);
  }

  Future<void> cancelHourlyAzkar() async {
    await _notificationService.cancel(3000);
  }

  Future<void> scheduleAllNotifications({
    required double lat,
    required double lng,
    required String country,
    required bool enablePrayers,
    required bool enableAzkar,
    bool force = false,
  }) async {
    final now = DateTime.now();

    // Clear existing notifications based on user preferences
    if (enablePrayers) await cancelAllPrayers();
    if (enableAzkar) await cancelMorningNightAzkar();

    int prayerIdCounter = 1000;
    int azkarIdCounter = 2000;

    // Loop only once for the next 7 days
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final prayers = _adhanService.getPrayersForDate(lat, lng, country, date);

      // Schedule Prayers
      if (enablePrayers) {
        final dailyPrayers = [
          ('صلاة الفجر', prayers.fajr),
          ('صلاة الشروق', prayers.sunrise),
          ('صلاة الظهر', prayers.dhuhr),
          ('صلاة العصر', prayers.asr),
          ('صلاة المغرب', prayers.maghrib),
          ('صلاة العشاء', prayers.isha),
        ];
        for (final (name, time) in dailyPrayers) {
          await _notificationService.scheduleZoned(
            id: prayerIdCounter++,
            title: name,
            body: 'حان الآن موعد $name | ${time.format12Hour()}',
            time: time,
          );
        }
      }

      // Schedule Azkar
      if (enableAzkar) {
        await _notificationService.scheduleZoned(
          id: azkarIdCounter++,
          title: 'أذكار الصباح',
          body: 'حان وقت أذكار الصباح',
          time: prayers.fajr.add(const Duration(minutes: 10)),
        );

        await _notificationService.scheduleZoned(
          id: azkarIdCounter++,
          title: 'أذكار المساء',
          body: 'حان وقت أذكار المساء',
          time: prayers.asr.add(const Duration(minutes: 10)),
        );
      }
    }

    // Update the cache only if scheduling actually occurred
    if (enablePrayers || enableAzkar) {
      await CacheService.cacheLastScheduledDate(
        now.add(const Duration(days: 6)).toIso8601String(),
      );
      await CacheService.cacheScheduledCoordinates(lat, lng);
    }
  }
}

extension Format12HourExt on DateTime {
  String format12Hour() {
    final int hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final String minutes = minute.toString().padLeft(2, '0');
    final String period = hour < 12 ? 'ص' : 'م';
    return '$hour12:$minutes $period';
  }
}
