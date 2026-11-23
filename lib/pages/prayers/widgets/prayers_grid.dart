import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project_azkar/pages/prayers/models/prayer_model.dart';
import 'package:project_azkar/data/repos/prayers_repo.dart';
import 'package:project_azkar/pages/prayers/prayer_details.dart';

import '../../../utils/app_colors.dart';

class PrayersGrid extends StatelessWidget {
  const PrayersGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 157,
        ),
        itemCount: PrayersRepo.allPrayers.length,
        itemBuilder: (context, index) =>
            PrayerCard(PrayersRepo.allPrayers[index]),
      ),
    );
  }
}

class PrayerCard extends StatelessWidget {
  final PrayerModel prayer;
  const PrayerCard(this.prayer, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        splashColor: AppColors.primary.withAlpha(50),
        highlightColor: Colors.transparent,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PrayerDetails(prayer)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.accent.withValues(alpha: .1),
                radius: 28,
                child: prayer.iconData != null
                    ? Icon(prayer.iconData, color: AppColors.accent, size: 28)
                    : SvgPicture.asset(
                        prayer.iconPath!,
                        width: 24,
                        colorFilter: ColorFilter.mode(
                          AppColors.accent,
                          BlendMode.srcIn,
                        ),
                      ),
              ),
              Text(
                prayer.title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              // Text(
              //   'دعاء و توجية',
              //   style: Theme.of(
              //     context,
              //   ).textTheme.bodySmall?.copyWith(color: AppColors.hint),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
