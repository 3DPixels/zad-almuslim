import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_azkar/cubits/prayer_times_cubit.dart';
import 'package:project_azkar/pages/home/widgets/prayer_time.dart';
import 'package:project_azkar/pages/home/widgets/time_remaining_container.dart';

import '../../../extensions/date_time_extnesions.dart';
import '../../../utils/app_colors.dart';

class SummaryCard extends StatefulWidget {
  const SummaryCard({super.key});

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToCurrentPrayer(int index) {
    if (index == -1 || !_scrollController.hasClients) return;

    // Estimate width of a single item + spacing (approx 80px item + 16px padding)
    const double itemWidth = 96.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      double screenWidth = MediaQuery.of(context).size.width;

      // Calculate offset to center the item
      double offset = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

      // Prevent scrolling past limits
      offset = offset.clamp(0.0, _scrollController.position.maxScrollExtent);

      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
      builder: (context, state) {
        if (state.currentPrayerIndex != -1) {
          _scrollToCurrentPrayer(state.currentPrayerIndex);
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            color: const Color(0xFF1A2A1F), // solid base color
            borderRadius: BorderRadius.circular(16),
            elevation: 3,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.darkGreenPageBG.withValues(alpha: .8),
                    AppColors.darkGreenPageBG.withValues(alpha: .4),
                    AppColors.darkGreenPageBG.withAlpha(0),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                spacing: 16,
                children: [
                  // First Row: Location, Hijri Date, Prayer Name, Countdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: .start,
                    spacing: 10,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 6,
                          children: [
                            Row(
                              spacing: 4,
                              children: [
                                Flexible(
                                  child: Text(
                                    '${state.city}، ${state.country}',
                                    overflow: .ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                  ),
                                ),
                                if (state.locationStatus ==
                                    LocationStatus.loading)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 5.0),
                                    child: SizedBox(
                                      height: 12,
                                      width: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                if (state.locationStatus !=
                                    LocationStatus.loading)
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                              ],
                            ),
                            Text(
                              DateTime.now().toHijriString(),
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      TimeRemainingContainer(
                        targetTime: state.timerTarget,
                        isPostAdhan: state.isPostAdhan,
                        onTimerComplete: () {
                          // Re-trigger calculation to transition state
                          context.read<PrayerTimesCubit>().calculatePrayers();
                        },
                      ),
                    ],
                  ),

                  // Second Row: Horizontal Prayers List
                  if (state.prayers.isNotEmpty)
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: state.prayers.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 30),
                        itemBuilder: (context, index) {
                          final prayer = state.prayers[index];
                          return PrayerTime(
                            passed: prayer.isPassed,
                            currentPrayer: prayer.isCurrent,
                            prayer: prayer.name,
                            prayerTime: prayer.timeString,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
