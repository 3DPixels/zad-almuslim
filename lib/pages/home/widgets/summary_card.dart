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
  // Keys for each prayer item so we can center the active prayer accurately
  // regardless of how large the text/display size is.
  final Map<int, GlobalKey> _prayerKeys = {};

  GlobalKey _keyForIndex(int index) =>
      _prayerKeys.putIfAbsent(index, () => GlobalKey());

  void _scrollToCurrentPrayer(int index) {
    if (index == -1) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyContext = _prayerKeys[index]?.currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(
          keyContext,
          alignment: 0.5,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Read screen width (shrinks when OS Display Size increases, e.g., 411 -> 320)
    final double screenWidth = MediaQuery.sizeOf(context).width;
    // 2. Read current text scale factor (1.0 is default, > 1.0 means OS Font Size increased)
    final double textScale = MediaQuery.textScalerOf(context).scale(1.0);

    // 3. Calculate how cramped the screen is by dividing width by textScale:
    // - Default phone (400px width / 1.0 scale) = 400
    // - Slightly zoomed/larger font = ~310 - 340
    // - Heavily zoomed + large font = < 300
    final double effectiveSpace = screenWidth / textScale;

    // Stage 1/2: If space is getting tight (< 345), scale down location/date font slightly (0.85x)
    final double fontMultiplier = effectiveSpace < 345 ? 0.85 : 1.0;

    // Stage 3: If space is very tight (< 305), switch from Row to Column layout!
    final bool useColumnLayout = effectiveSpace < 305;

    return BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
      builder: (context, state) {
        if (state.currentPrayerIndex != -1) {
          _scrollToCurrentPrayer(state.currentPrayerIndex);
        }

        final timerWidget = TimeRemainingContainer(
          targetTime: state.timerTarget,
          isPostAdhan: state.isPostAdhan,
          onTimerComplete: () {
            context.read<PrayerTimesCubit>().calculatePrayers();
          },
        );

        final locationStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 22 * fontMultiplier,
        );

        final hijriStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white70,
          fontSize: 16 * fontMultiplier,
        );

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
                  // HEADER: Switches between Column and Row
                  if (useColumnLayout)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 12,
                      children: [
                        timerWidget,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12,
                          children: [
                            Expanded(
                              child: _buildLocationRow(
                                context: context,
                                state: state,
                                style: hijriStyle!.copyWith(
                                  color: AppColors.primary,
                                ),
                                textScale: textScale,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                DateTime.now().toHijriString(),
                                textAlign: TextAlign.end,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: hijriStyle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 5,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 6,
                              children: [
                                _buildLocationRow(
                                  context: context,
                                  state: state,
                                  style: locationStyle,
                                  textScale: textScale,
                                ),
                                Text(
                                  DateTime.now().toHijriString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: hijriStyle,
                                ),
                              ],
                            ),
                          ),
                          timerWidget,
                        ],
                      ),
                    ),

                  // PRAYERS LIST
                  if (state.prayers.isNotEmpty)
                    SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 28,
                        children: List.generate(state.prayers.length, (index) {
                          final prayer = state.prayers[index];
                          return KeyedSubtree(
                            key: _keyForIndex(index),
                            child: PrayerTime(
                              passed: prayer.isPassed,
                              currentPrayer: prayer.isCurrent,
                              prayer: prayer.name,
                              prayerTime: prayer.timeString,
                            ),
                          );
                        }),
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

Widget _buildLocationRow({
  required BuildContext context,
  required PrayerTimesState state,
  required TextStyle? style,
  required double textScale,
}) {
  // Base size is 18, scaled up with our global textScale
  final double pinIconSize = 18.0 * textScale;

  return Wrap(
    spacing: 4,
    runSpacing: 8,
    children: [
      Text('${state.city}، ', overflow: TextOverflow.ellipsis, style: style),
      Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Flexible(
            child: Text(
              state.country,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
          if (state.locationStatus == LocationStatus.loading)
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: SizedBox(
                height: pinIconSize * 0.8,
                width: pinIconSize * 0.8,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.green,
                ),
              ),
            )
          else
            Icon(
              Icons.location_on,
              size: pinIconSize,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    ],
  );
}
