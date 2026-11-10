import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_azkar/utils/app_colors.dart';
import 'package:reel_text/reel_text.dart';

import '../../../cubits/azkar_cubit.dart';
import 'azkar_single_card.dart';

class AzkarSingle extends StatelessWidget {
  const AzkarSingle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AzkarCubit, AzkarState, ZekrStateItem?>(
      selector: (state) =>
          state.unreadItems.isNotEmpty ? state.unreadItems.first : null,
      builder: (context, currentItem) {
        if (currentItem == null) {
          return const Center(
            child: Text(
              'تم الانتهاء من جميع الأذكار!',
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
          );
        }

        final supplication = currentItem.supplication;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
          child: Column(
            children: [
              AzkarSingleCard(
                key: ValueKey(supplication.dua),
                supplication: supplication,
              ),
              SizedBox(height: 25),
              GestureDetector(
                onTap: () =>
                    context.read<AzkarCubit>().decrementCount(supplication),
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
                    '${currentItem.currentCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 22),
              const Text(
                'اضغط للعد',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}
