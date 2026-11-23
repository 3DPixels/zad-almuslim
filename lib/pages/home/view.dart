import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_azkar/pages/home/widgets/permission_dialog.dart';

import 'cubits/prayer_times_cubit.dart';
import '../settings/cubits/settings_cubit.dart';
import 'body.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  // Setting this to true tells Flutter not to destroy the widget
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // This super call is required for the mixin to work correctly
    super.build(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<PrayerTimesCubit, PrayerTimesState>(
          listenWhen: (previous, current) =>
              previous.locationStatus != current.locationStatus,
          listener: (context, state) {
            if (state.locationStatus == LocationStatus.serviceDisabled) {
              PermissionDialog.show(
                context,
                title: 'خدمة الموقع معطلة',
                content: 'يرجى تفعيل خدمة الموقع.',
              );
            } else if (state.locationStatus ==
                LocationStatus.permissionDenied) {
              PermissionDialog.show(
                context,
                title: 'صلاحية مطلوبة',
                content: 'التطبيق يحتاج إلى صلاحية الموقع.',
              );
            } else if (state.locationStatus ==
                LocationStatus.permissionPermanentlyDenied) {
              PermissionDialog.show(
                context,
                title: 'صلاحية مرفوضة نهائياً',
                content: 'التطبيق لا يعمل بدون صلاحية الموقع.',
                isPermanent: true,
              );
            }
          },
        ),
        BlocListener<PrayerTimesCubit, PrayerTimesState>(
          listenWhen: (previous, current) {
            // Wait until location resolution has settled (avoiding initial & loading)
            final isCurrentResolved =
                current.locationStatus != LocationStatus.initial &&
                current.locationStatus != LocationStatus.loading;
            final wasPending =
                previous.locationStatus == LocationStatus.initial ||
                previous.locationStatus == LocationStatus.loading;

            final coordinatesChanged =
                previous.latitude != current.latitude ||
                previous.longitude != current.longitude;

            return isCurrentResolved && (wasPending || coordinatesChanged);
          },
          listener: (context, state) {
            context.read<SettingsCubit>().scheduleNotifications(
              lat: state.latitude,
              lng: state.longitude,
              country: state.country,
              force: state.isManualRefresh,
            );
          },
        ),
      ],
      child: const Body(),
    );
  }
}
