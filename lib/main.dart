import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_azkar/pages/main_page.dart';
import 'package:project_azkar/services/cache_service.dart';
import 'package:project_azkar/utils/dark_theme.dart';

import 'cubits/prayer_times_cubit.dart';
import 'cubits/settings_cubit.dart';
import 'l10n/app_localizations.dart';
import 'services/adhan_service.dart';
import 'services/location_service.dart';
import 'services/notification_scheduler.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheService.init();
  final notificationService = NotificationService();
  await notificationService.init();

  final adhanService = AdhanService();
  final locationService = LocationService();
  final scheduler = NotificationScheduler(adhanService, notificationService);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) => runApp(
      MyApp(
        adhanService: adhanService,
        locationService: locationService,
        notifiService: notificationService,
        scheduler: scheduler,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AdhanService adhanService;
  final LocationService locationService;
  final NotificationService notifiService;
  final NotificationScheduler scheduler;

  const MyApp({
    super.key,
    required this.adhanService,
    required this.locationService,
    required this.notifiService,
    required this.scheduler,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PrayerTimesCubit(locationService, adhanService),
        ),
        BlocProvider(
          create: (_) => SettingsCubit(scheduler, notifiService),
          lazy: false,
        ),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Azkar App',
        locale: Locale('ar', 'SA'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: [Locale('ar')],
        theme: darkTheme(),
        // builder wraps every screen in the app so we can control scaling globally!
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          // 1. Read the raw OS font scale factor (1.0 is default, > 1.0 means increased)
          final double rawScale = mediaQuery.textScaler.scale(1.0);
          // 2. If default or smaller (<= 1.0), clamp to 1.0.
          // If increased (> 1.0), take only HALF of the increase, and cap at 1.35 max.
          final double dampenedScale = rawScale <= 1.0
              ? rawScale.clamp(1, 1)
              : (1.0 + (rawScale - 1.0) * 0.5).clamp(1.0, 1.35);
          return MediaQuery(
            // Apply our safe, dampened text scale to all Text widgets in the app
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(dampenedScale),
            ),
            // Globally scale all default Icon widgets (24.0 base size * dampenedScale)
            child: IconTheme(
              data: IconTheme.of(context).copyWith(size: 24.0 * dampenedScale),
              child: child!,
            ),
          );
        },
        home: const MainPage(),
      ),
    );
  }
}
