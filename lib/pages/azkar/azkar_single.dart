import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_azkar/utils/app_colors.dart';
import 'package:reel_text/reel_text.dart';

import 'cubits/azkar_cubit.dart';
import 'widgets/azkar_single_card.dart';

class AzkarSingle extends StatefulWidget {
  const AzkarSingle({super.key});

  @override
  State<AzkarSingle> createState() => _AzkarSingleState();
}

class _AzkarSingleState extends State<AzkarSingle> {
  late final PageController _pageController;
  int _currentIndex = 0;
  bool _isAutoAdvancing = false;

  @override
  void initState() {
    super.initState();
    final items = context.read<AzkarCubit>().state.items;
    final firstUnread = items.indexWhere((e) => !e.isCompleted);
    _currentIndex = firstUnread != -1 ? firstUnread : 0;

    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.88,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int newIndex) {
    final previousIndex = _currentIndex;
    setState(() {
      _currentIndex = newIndex;
      _isAutoAdvancing = false;
    });
    // Reset recount counter on the card we just left so revisiting starts fresh
    context.read<AzkarCubit>().resetRecount(previousIndex);
  }

  Future<void> _onCounterTap(int totalCount) async {
    if (_isAutoAdvancing) return;

    final cubit = context.read<AzkarCubit>();
    final index = _currentIndex;
    final hitZero = cubit.decrementSingleCount(index);

    // Auto-advance unless this is the last card or all azkar just completed
    final allCompleted = cubit.state.unreadItems.isEmpty;
    if (hitZero && !allCompleted && index < totalCount - 1) {
      _isAutoAdvancing = true;
      await Future.delayed(const Duration(milliseconds: 260));
      if (!mounted) return;

      if (_currentIndex == index && _pageController.hasClients) {
        await _pageController.nextPage(
          duration: const Duration(milliseconds: 340),
          curve: Curves.easeOutCubic,
        );
      }
      _isAutoAdvancing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarCubit, AzkarState>(
      builder: (context, state) {
        if (state.items.isEmpty) {
          return const Center(
            child: Text(
              'لا توجد أذكار',
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
          );
        }

        final safeIndex = _currentIndex.clamp(0, state.items.length - 1);
        final currentItem = state.items[safeIndex];

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 20.0),
            child: Column(
              children: [
                // Centered Carousel with Peeking Adjacent Cards
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    padEnds: true,
                    itemCount: state.items.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      final item = state.items[index];

                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double page = safeIndex.toDouble();
                          if (_pageController.position.hasContentDimensions) {
                            page = _pageController.page ?? safeIndex.toDouble();
                          }
                          final distance = (page - index).abs().clamp(0.0, 1.0);
                          final scale = 1.0 - (distance * 0.06);
                          final opacity = 1.0 - (distance * 0.45);

                          return Transform.scale(
                            scale: scale,
                            child: Opacity(opacity: opacity, child: child),
                          );
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                            ),
                            child: AzkarSingleCard(
                              supplication: item.supplication,
                              isCompleted: item.isCompleted,
                              cardNumber: index + 1,
                              totalCards: state.items.length,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Counter Button
                GestureDetector(
                  onTap: () => _onCounterTap(state.items.length),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: ReelText(
                      '${currentItem.singleDisplayCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  currentItem.isCompleted
                      ? 'تمت قراءته • اضغط للإعادة'
                      : 'اضغط للعد',
                  style: TextStyle(
                    color: currentItem.isCompleted
                        ? AppColors.primary
                        : Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
