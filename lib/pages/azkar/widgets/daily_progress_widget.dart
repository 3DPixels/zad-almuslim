import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/azkar_cubit.dart';
import '../../../utils/app_colors.dart';

class DailyProgressWidget extends StatelessWidget {
  const DailyProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds ONLY this small widget when any of these 3 values change
    final data = context.select(
      (AzkarCubit cubit) => (
        completed: cubit.state.completedZekr,
        total: cubit.state.totalZekr,
        progress: cubit.state.progress,
      ),
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('التقدم اليومي'),
            Text('${data.completed}/${data.total}'),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: data.progress),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          builder: (context, animatedValue, child) {
            return LinearProgressIndicator(
              value: animatedValue,
              backgroundColor: AppColors.darkGreenSurface,
              color: AppColors.primary,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            );
          },
        ),
      ],
    );
  }
}
