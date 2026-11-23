import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_azkar/utils/app_colors.dart';
import 'package:project_azkar/utils/enums.dart';

import '../../../data/models/dua_model.dart';
import 'azkar_list.dart';
import 'azkar_single.dart';
import 'completion_page.dart';
import 'cubits/azkar_cubit.dart';
import 'widgets/custom_tab_bar.dart';
import 'widgets/daily_progress_widget.dart';

class AzkarPage extends StatelessWidget {
  final String title;
  final List<DuaModel> allSupplications;
  final DuaTime duaTime;

  /// true: title expands as soon as you scroll up.
  /// false: title expands only when you return to the top of AzkarList.
  final bool expandOnScrollUp;

  const AzkarPage({
    super.key,
    required this.allSupplications,
    required this.title,
    required this.duaTime,
    this.expandOnScrollUp = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AzkarCubit(initialSupplications: allSupplications, duaTime: duaTime),
      child: BlocListener<AzkarCubit, AzkarState>(
        listenWhen: (previous, current) =>
            previous.unreadItems.isNotEmpty && current.unreadItems.isEmpty,
        listener: (context, state) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CompletionPage(
                totalRead: state.totalCategoryReps,
                addedInSession: state.sessionRepsRead,
              ),
            ),
          );
        },
        child: _AzkarPageBody(title: title, expandOnScrollUp: expandOnScrollUp),
      ),
    );
  }
}

class _AzkarPageBody extends StatefulWidget {
  final String title;
  final bool expandOnScrollUp;

  const _AzkarPageBody({required this.title, required this.expandOnScrollUp});

  @override
  State<_AzkarPageBody> createState() => _AzkarPageBodyState();
}

class _AzkarPageBodyState extends State<_AzkarPageBody> {
  int _selectedIndex = 0;
  bool _isTitleCollapsed = false;

  void _onTabSelected(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
      // Immediately expand on the exact same frame when entering AzkarSingle
      if (index == 1) {
        _isTitleCollapsed = false;
      }
    });
  }

  bool _onListScroll(ScrollUpdateNotification notification) {
    if (_selectedIndex != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }

    final pixels = notification.metrics.pixels;
    final maxExtent = notification.metrics.maxScrollExtent;
    final delta = notification.scrollDelta ?? 0;

    if (widget.expandOnScrollUp) {
      if (!_isTitleCollapsed && delta > 4 && pixels > 24 && maxExtent > 80) {
        setState(() => _isTitleCollapsed = true);
      } else if (_isTitleCollapsed && (delta < -4 || pixels <= 8)) {
        setState(() => _isTitleCollapsed = false);
      }
    } else {
      if (!_isTitleCollapsed && pixels > 30 && maxExtent > 80) {
        setState(() => _isTitleCollapsed = true);
      } else if (_isTitleCollapsed && pixels <= 8) {
        setState(() => _isTitleCollapsed = false);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final dir = isRtl ? -1.0 : 1.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final sessionReps = context.read<AzkarCubit>().state.sessionRepsRead;
        Navigator.of(context).pop(sessionReps);
      },
      child: Scaffold(
        backgroundColor: AppColors.darkGreenPageBG,
        body: Column(
          children: [
            // Shared Header (Title collapses; Progress & TabBar always stay visible)
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkGreenPageBG,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                  child: Column(
                    children: [
                      ClipRect(
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.bottomCenter,
                          heightFactor: _isTitleCollapsed ? 0.0 : 1.0,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 180),
                            opacity: _isTitleCollapsed ? 0.0 : 1.0,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 14.0,
                                bottom: 14.0,
                              ),
                              child: Text(
                                widget.title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 6.0),
                        child: DailyProgressWidget(),
                      ),
                      const SizedBox(height: 16),
                      CustomTabBar(
                        selectedIndex: _selectedIndex,
                        onChanged: _onTabSelected,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Body: keeps both views mounted (preserves scroll + carousel index)
            // while animating smoothly on switch
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _AnimatedTabSlot(
                    isActive: _selectedIndex == 0,
                    inactiveOffset: Offset(-0.06 * dir, 0),
                    child: NotificationListener<ScrollUpdateNotification>(
                      onNotification: _onListScroll,
                      child: const AzkarList(),
                    ),
                  ),
                  _AnimatedTabSlot(
                    isActive: _selectedIndex == 1,
                    inactiveOffset: Offset(0.06 * dir, 0),
                    child: const AzkarSingle(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedTabSlot extends StatelessWidget {
  final bool isActive;
  final Offset inactiveOffset;
  final Widget child;

  const _AnimatedTabSlot({
    required this.isActive,
    required this.inactiveOffset,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isActive,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        offset: isActive ? Offset.zero : inactiveOffset,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          opacity: isActive ? 1.0 : 0.0,
          child: TickerMode(enabled: isActive, child: child),
        ),
      ),
    );
  }
}
