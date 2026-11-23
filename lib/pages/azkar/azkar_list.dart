import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_azkar/widgets/dua_card.dart';
import 'package:project_azkar/utils/app_colors.dart';

import 'cubits/azkar_cubit.dart';

class AzkarList extends StatelessWidget {
  const AzkarList({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey<String>('list_tab'),
      slivers: [
        // Choice Chips
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: ListChoiceChips(),
          ),
        ),

        // List View Container
        BlocSelector<AzkarCubit, AzkarState, List<ZekrStateItem>>(
          selector: (state) =>
              state.showReadList ? state.readItems : state.unreadItems,
          builder: (context, displayItems) {
            if (displayItems.isEmpty) {
              final showRead = context.select(
                (AzkarCubit c) => c.state.showReadList,
              );
              return SliverFillRemaining(
                child: !showRead
                    ? Row(
                        spacing: 5,
                        mainAxisAlignment: .center,
                        children: [
                          Text('تم الانتهاء من الأذكار!'),
                          Icon(Icons.check_circle_outline),
                        ],
                      )
                    : Center(child: Text('لا توجد أذكار مقروءة')),
              );
            }

            return SliverList.builder(
              itemCount: displayItems.length,
              itemBuilder: (context, index) {
                final initialItem = displayItems[index];
                return BlocSelector<AzkarCubit, AzkarState, ZekrStateItem>(
                  key: ValueKey(initialItem.supplication.dua),
                  selector: (state) => state.items.firstWhere(
                    (e) => e.supplication == initialItem.supplication,
                    orElse: () => initialItem,
                  ),
                  builder: (context, item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DuaCard(
                        supplication: item.supplication,
                        buttonsColor: AppColors.primary,
                        borderColor: AppColors.primary.withValues(alpha: 0.15),
                        bottomColor: AppColors.darkGreenNavBarBG,
                        containerBackgroundColor: AppColors.darkGreenSurface,
                        enableCounter: true,
                        currentCount: item.currentCount,
                        targetCount: item.targetCount,
                        onTap: () => context.read<AzkarCubit>().decrementCount(
                          item.supplication,
                        ),
                        onUndo: () => context.read<AzkarCubit>().undoCount(
                          item.supplication,
                        ),
                        onSkip: () => context.read<AzkarCubit>().skipZekr(
                          item.supplication,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class ListChoiceChips extends StatelessWidget {
  const ListChoiceChips({super.key});

  Future<void> _confirmRestoreAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.darkGreenSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        title: const Text('إعادة جميع الأذكار'),
        content: const Text(
          'سيتم إعادة جميع الأذكار المقروءة إلى قائمة الأذكار الباقية مع الاحتفاظ بمجموعك الكلي.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('إعادة الكل'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AzkarCubit>().restoreAllRead();
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.select(
      (AzkarCubit cubit) => (
        showReadList: cubit.state.showReadList,
        hasReadItems: cubit.state.completedZekr > 0,
      ),
    );

    return Row(
      children: [
        ChoiceChip(
          label: const Text('أذكار باقية'),
          selected: !data.showReadList,
          onSelected: (_) => context.read<AzkarCubit>().toggleList(false),
          selectedColor: AppColors.primary.withValues(alpha: 0.2),
          checkmarkColor: AppColors.primary,
          backgroundColor: AppColors.darkGreenSurface,
        ),
        const SizedBox(width: 12),
        ChoiceChip(
          label: const Text('تمت قراءتها'),
          selected: data.showReadList,
          onSelected: (_) => context.read<AzkarCubit>().toggleList(true),
          selectedColor: AppColors.primary.withValues(alpha: 0.2),
          checkmarkColor: AppColors.primary,
          backgroundColor: AppColors.darkGreenSurface,
        ),
        const Spacer(),
        if (data.hasReadItems)
          IconButton(
            tooltip: 'إعادة الأذكار المقروءة',
            onPressed: () => _confirmRestoreAll(context),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.darkGreenSurface,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
            ),
            icon: const Icon(Icons.restart_alt_rounded, size: 20),
          ),
      ],
    );
  }
}
