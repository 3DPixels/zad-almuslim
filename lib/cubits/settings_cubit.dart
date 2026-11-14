import 'package:adhan/adhan.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/cache_service.dart';
import '../../services/notification_service.dart';
import '../../services/notification_scheduler.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final NotificationScheduler _scheduler;
  final NotificationService _notificationService;

  SettingsCubit(this._scheduler, this._notificationService)
    : super(const SettingsState()) {
    _init();
  }

  Future<void> _init() async {
    bool isPrayersOn = CacheService.getPrayerToggle();
    bool isDailyOn = CacheService.getDailyAzkarToggle();
    bool isMorningNightOn = CacheService.getMorningNightAzkarToggle();

    // Check silently without displaying an OS permission dialog on startup
    final hasPermissions = await _notificationService.checkPermissions();

    // Fallback: If toggles were saved as ON but OS permissions were revoked, turn toggles OFF
    if (!hasPermissions) {
      if (isPrayersOn) {
        isPrayersOn = false;
        await CacheService.cachePrayerToggle(false);
        // CHANGED: Also clear any previously scheduled prayer alarms & metadata
        await _scheduler.cancelAllPrayers();
      }
      if (isDailyOn) {
        isDailyOn = false;
        await CacheService.cacheDailyAzkarToggle(false);
      }
      if (isMorningNightOn) {
        isMorningNightOn = false;
        await CacheService.cacheMorningNightAzkarToggle(false);
        // CHANGED: Also clear any previously scheduled morning/night Azkar alarms
        await _scheduler.cancelMorningNightAzkar();
      }
    }

    emit(
      SettingsState(
        prayerNotifications: isPrayersOn,
        dailyAzkarNotifications: isDailyOn,
        morningNightAzkarNotifications: isMorningNightOn,
      ),
    );
  }

  /// Synchronizes schedules once location status has settled (GPS, cache, or fallback).
  Future<void> scheduleNotifications({
    required double lat,
    required double lng,
    required String country,
    bool force = false,
  }) async {
    // CHANGED: Verify both permissions are granted before attempting to schedule on app start/refresh
    final hasPermissions = await _notificationService.checkPermissions();
    if (!hasPermissions) return;

    // Runs on app start. force is false. It will only schedule if the cache requires it.
    await _scheduler.scheduleAllNotifications(
      lat: lat,
      lng: lng,
      country: country,
      enablePrayers: state.prayerNotifications,
      enableAzkar: state.morningNightAzkarNotifications,
      force: force,
    );
  }

  Future<void> togglePrayerNotifications(
    bool value, {
    required double lat,
    required double lng,
    required String country,
  }) async {
    if (value) {
      final granted = await _notificationService.requestPermissions();
      if (!granted) return;

      emit(state.copyWith(prayerNotifications: true));
      await CacheService.cachePrayerToggle(true);

      // FORCE: TRUE. User just turned prayers ON, schedule them immediately.
      await _scheduler.scheduleAllNotifications(
        lat: lat,
        lng: lng,
        country: country,
        enablePrayers: true, // newly toggled value
        enableAzkar: state.morningNightAzkarNotifications,
        force: true,
      );
    } else {
      emit(state.copyWith(prayerNotifications: false));
      await CacheService.cachePrayerToggle(false);
      await _scheduler.cancelAllPrayers();
    }
  }

  Future<void> toggleMorningNightAzkar(
    bool value, {
    required double lat,
    required double lng,
    required String country,
  }) async {
    if (value) {
      final granted = await _notificationService.requestPermissions();
      if (!granted) return;

      emit(state.copyWith(morningNightAzkarNotifications: true));
      await CacheService.cacheMorningNightAzkarToggle(true);

      // FORCE: TRUE. User just turned Azkar ON, schedule them immediately.
      await _scheduler.scheduleAllNotifications(
        lat: lat,
        lng: lng,
        country: country,
        enablePrayers: state.prayerNotifications, // keep existing prayer state
        enableAzkar: true, // newly toggled value
        force: true,
      );
    } else {
      emit(state.copyWith(morningNightAzkarNotifications: false));
      await CacheService.cacheMorningNightAzkarToggle(false);
      await _scheduler.cancelMorningNightAzkar();
    }
  }

  // Future<void> toggleDailyAzkar(bool value) async {
  //   if (value) {
  //     final granted = await NotificationService().requestPermissions();
  //     if (!granted) return;
  //     emit(state.copyWith(dailyAzkarNotifications: true));
  //     await CacheService.cacheDailyAzkarToggle(true);
  //     await _scheduler.scheduleHourlyAzkar();
  //   } else {
  //     emit(state.copyWith(dailyAzkarNotifications: false));
  //     await CacheService.cacheDailyAzkarToggle(false);
  //     await _scheduler.cancelHourlyAzkar();
  //   }
  // }

  void updateCalculationMethod(CalculationMethod? method) {
    if (method == null) {
      emit(state.copyWith(clearCalculationMethod: true));
    } else {
      emit(state.copyWith(selectedCalculationMethod: method));
    }
  }
}
