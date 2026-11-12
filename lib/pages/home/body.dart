import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/prayer_times_cubit.dart';
import '../../data/repos/mood_repo.dart';
import 'widgets/mood_container.dart';
import 'widgets/offline_banner.dart';
import 'widgets/summary_card.dart';
import '../supplications/moods/moods_list.dart';
import 'widgets/home_azkar_grid.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            await context.read<PrayerTimesCubit>().refreshLocation();
          },
          builder:
              (
                context,
                refreshState,
                pulledExtent,
                refreshTriggerPullDistance,
                refreshIndicatorExtent,
              ) {
                Widget indicator;

                switch (refreshState) {
                  case RefreshIndicatorMode.drag:
                    indicator = const Text(
                      "اسحب لتحديث الموقع",
                      style: TextStyle(color: Colors.white54),
                    );
                    break;
                  case RefreshIndicatorMode.armed:
                    indicator = const Text(
                      "أفلت للتحديث",
                      style: TextStyle(color: Colors.white),
                    );
                    break;
                  case RefreshIndicatorMode.refresh:
                  case RefreshIndicatorMode.done:
                    indicator = Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "جاري تحديث الموقع...",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    );
                    break;
                  case RefreshIndicatorMode.inactive:
                    indicator = const SizedBox.shrink();
                    break;
                }

                return Container(
                  alignment: Alignment.center,
                  height: pulledExtent,
                  child: indicator,
                );
              },
        ),
        SliverToBoxAdapter(
          child: BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
            buildWhen: (previous, current) =>
                previous.locationStatus != current.locationStatus,
            builder: (context, state) {
              final isOfflineOrFallback =
                  state.locationStatus == LocationStatus.serviceDisabled ||
                  state.locationStatus == LocationStatus.permissionDenied ||
                  state.locationStatus ==
                      LocationStatus.permissionPermanentlyDenied;
              if (isOfflineOrFallback) {
                return const OfflineBanner();
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        // Prayer card
        SliverToBoxAdapter(child: SummaryCard()),
        const SliverToBoxAdapter(child: SizedBox(height: 18)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'بماذا تشعر اليوم؟',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                // TextButton(child: Text('عرض الكل'), onPressed: () {}),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 18)),

        // Moods
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              spacing: 16,
              children: MoodRepo.allMoods
                  .map(
                    (mood) => MoodContainer(
                      title: mood.header,
                      iconData: mood.icon,
                      iconColor: mood.colorPalette.mainColor,
                      detailsPage: MoodsList(mood),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 18)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'الأذكار اليومية',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 18)),
        SliverPadding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
          sliver: HomeAzkarGrid(),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 18)),
      ],
    );
  }
}
