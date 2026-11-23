import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../extensions/date_time_extensions.dart';
import 'adhan_service.dart';
import 'cache_service.dart';
import 'notification_service.dart';

class NotificationScheduler {
  final AdhanService _adhanService;
  final NotificationService _notificationService;

  // Queue that forces all cancel/schedule operations to run one after another.
  // Prevents a user toggle and a GPS refresh from colliding and wiping each other's alarms.
  Future<void> _operationQueue = Future.value();

  NotificationScheduler(this._adhanService, this._notificationService);

  /// Runs [action] only after any previous scheduling/cancelling finishes.
  Future<T> _enqueue<T>(Future<T> Function() action) {
    final completer = Completer<T>();

    // Chain the new action onto whatever is currently at the back of the line
    _operationQueue = _operationQueue.then((_) async {
      try {
        completer.complete(await action());
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });

    // Give the caller a Future that completes when *their* specific action finishes
    return completer.future;
  }

  // Private internal helpers (never call public enqueued methods from inside _enqueue, or it will deadlock)
  Future<void> _cancelAllPrayersInternal() async {
    await _notificationService.cancelRange(1000, 1045);
    await CacheService.clearScheduleMeta();
  }

  Future<void> _cancelMorningNightAzkarInternal() async {
    await _notificationService.cancelRange(2000, 2014);
  }

  Future<void> cancelAllPrayers() => _enqueue(_cancelAllPrayersInternal);

  Future<void> cancelMorningNightAzkar() =>
      _enqueue(_cancelMorningNightAzkarInternal);

  Future<void> cancelHourlyAzkar() =>
      _enqueue(() => _notificationService.cancel(3000));

  Future<void> scheduleAllNotifications({
    required double lat,
    required double lng,
    required String country,
    required bool enablePrayers,
    required bool enableAzkar,
    bool force = false,
  }) {
    return _enqueue(() async {
      // Early exit: don't run the 7-day calculation loop if both toggles are OFF
      if (!enablePrayers && !enableAzkar) return;

      final now = DateTime.now();
      final lastScheduledString = CacheService.getLastScheduledDate();
      final scheduledCoords = CacheService.getScheduledCoordinates();

      // 1. Check if we can skip scheduling
      if (!force && lastScheduledString != null && scheduledCoords != null) {
        final lastDate = DateTime.tryParse(lastScheduledString);
        final double distance = Geolocator.distanceBetween(
          scheduledCoords.lat,
          scheduledCoords.lng,
          lat,
          lng,
        );

        final daysLeft = lastDate?.difference(now).inDays;

        // Keep schedule if within 20km and >= 3 days left
        if (distance < 20000 &&
            daysLeft != null &&
            daysLeft >= 3 &&
            daysLeft <= 7) {
          return; // Schedule is still valid, do nothing
        }
      }

      // 2. Clear existing notifications (using internal methods to avoid queue deadlock)
      if (enablePrayers) await _cancelAllPrayersInternal();
      if (enableAzkar) await _cancelMorningNightAzkarInternal();

      int prayerIdCounter = 1000;
      int azkarIdCounter = 2000;

      // 3. Loop once for the next 7 days
      for (int i = 0; i < 7; i++) {
        final date = now.add(Duration(days: i));
        final prayers = _adhanService.getPrayersForDate(
          lat,
          lng,
          country,
          date,
        );

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

      // 4. Update schedule cache metadata
      await CacheService.cacheLastScheduledDate(
        now.add(const Duration(days: 6)).toIso8601String(),
      );
      await CacheService.cacheScheduledCoordinates(lat, lng);
    });
  }
}
