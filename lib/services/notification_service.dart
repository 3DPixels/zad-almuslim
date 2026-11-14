import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Initialize the notification service
  Future<void> init() async {
    tz.initializeTimeZones();
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(settings: settings);
  }

  /// Quietly checks if BOTH notification and exact alarm permissions are granted without prompting dialogs.
  Future<bool> checkPermissions() async {
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      // Check standard notification permission
      final notificationsEnabled =
          await androidImplementation.areNotificationsEnabled() ?? false;

      // Also check if SCHEDULE_EXACT_ALARM is granted
      final exactAlarmsEnabled =
          await androidImplementation.canScheduleExactNotifications() ?? false;

      // Both must be true for exact scheduled notifications to work
      return notificationsEnabled && exactAlarmsEnabled;
    }
    return false;
  }

  /// Prompts the user with the system notification dialog, then redirects to the
  /// system "Alarms & reminders" settings page if exact alarms are not yet allowed.
  Future<bool> requestPermissions() async {
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      // 1. Request standard POST_NOTIFICATIONS permission first
      final notifResult =
          await androidImplementation.requestNotificationsPermission() ?? false;
      if (!notifResult) return false;

      // 2. Check if SCHEDULE_EXACT_ALARM is already allowed
      bool exactAlarmResult =
          await androidImplementation.canScheduleExactNotifications() ?? false;

      // 3. If not allowed, open the system Settings page for Alarms & Reminders
      if (!exactAlarmResult) {
        exactAlarmResult =
            await androidImplementation.requestExactAlarmsPermission() ?? false;
      }

      return notifResult && exactAlarmResult;
    }
    return false;
  }

  Future<void> cancel(int id) async => await _plugin.cancel(id: id);

  Future<void> cancelRange(int startId, int endId) async {
    for (int i = startId; i <= endId; i++) {
      await _plugin.cancel(id: i);
    }
  }

  Future<void> scheduleZoned({
    String? title,
    String? body,
    required int id,
    required DateTime time,
  }) async {
    if (time.isBefore(DateTime.now())) return;

    // Guard against PlatformException(exact_alarms_not_permitted)
    // in case the user revoked the exact alarm permission in system settings.
    final hasPermission = await checkPermissions();
    if (!hasPermission) return;

    final tzTime = tz.TZDateTime.from(time, tz.local);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzTime,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'مواقيت الصلاة و اذكار يومية',
          groupKey: 'dalil_almuslim_group',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.reminder,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleRepeating({
    String? title,
    String? body,
    required int id,
  }) async {
    await _plugin.periodicallyShow(
      id: id,
      title: title,
      body: body,
      repeatInterval: RepeatInterval.hourly,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'hourly_azkar',
          'أذكار متكررة',
          groupKey: 'dalil_almuslim_group',
          category: AndroidNotificationCategory.reminder,
          playSound: false,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
    );
  }

  Future<void> showNotification() async {
    await _plugin.show(
      id: 0,
      title: 'title',
      body: 'body',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'hourly_azkar',
          'أذكار متكررة',
          groupKey: 'dalil_almuslim_group',
          category: AndroidNotificationCategory.reminder,
          playSound: false,
        ),
      ),
    );
  }
}
