import 'package:flutter/material.dart';
import 'package:project_azkar/data/repos/zekr_repo.dart';
import 'package:project_azkar/pages/azkar/azkar_page.dart';
import 'package:project_azkar/services/azkar_cache_service.dart';
import 'package:project_azkar/utils/app_icons.dart';
import 'package:project_azkar/utils/enums.dart';

import '../../../services/cache_service.dart';
import '../../../utils/app_colors.dart';
import '../models/card_pallete_model.dart';
import 'gradient_card.dart';

class AzkarCardData {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? iconPath;
  final CardPalette palette;
  final DuaTime duaTime;

  const AzkarCardData({
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconPath,
    required this.palette,
    required this.duaTime,
  });
}

final List<AzkarCardData> azkarCards = [
  AzkarCardData(
    title: 'أذكار الصباح',
    subtitle: 'بداية يوم مبارك',
    icon: Icons.wb_sunny,
    palette: const CardPalette(
      iconColor: Color(0xFFF28512),
      glowColor: Color(0xFF32281F),
      gradientColor: Color(0xFF332F20),
    ),
    duaTime: DuaTime.day, // Replace with your actual enum value
  ),
  AzkarCardData(
    title: 'أذكار المساء',
    subtitle: 'نهاية يوم هادئة',
    icon: Icons.nights_stay,
    palette: const CardPalette(
      iconColor: Color(0xFF7B85FA),
      glowColor: Color(0xFF1E202F),
      gradientColor: Color(0xFF222834),
    ),
    duaTime: DuaTime.night, // Replace with your actual enum value
  ),
  AzkarCardData(
    title: 'أذكار بعد الصلاة',
    subtitle: 'ختام الصلاة',
    iconPath: AppIcons.islamicSign,
    palette: const CardPalette(
      iconColor: Color(0xFF17CE55),
      glowColor: Color(0xFF15281A),
      gradientColor: Color(0xFF1B3622),
    ),
    duaTime: DuaTime.afterPrayer, // Replace with your actual enum value
  ),
  AzkarCardData(
    title: 'أذكار قبل النوم',
    subtitle: 'ختام اليوم',
    icon: Icons.bed,
    palette: const CardPalette(
      iconColor: Color(0xFFB983FC),
      glowColor: Color(0xFF211D2F),
      gradientColor: Color(0xFF282833),
    ),
    duaTime: DuaTime.beforeSleep, // Replace with your actual enum value
  ),
];

class HomeAzkarGrid extends StatefulWidget {
  const HomeAzkarGrid({super.key});

  @override
  State<HomeAzkarGrid> createState() => _HomeAzkarGridState();
}

class _HomeAzkarGridState extends State<HomeAzkarGrid> {
  Widget _buildCard(BuildContext context, AzkarCardData card) {
    final supplications = ZekrRepo.getAzkarByTime(card.duaTime);
    final dailyProgress = AzkarCacheService.getDailyProgress(
      card.duaTime,
      supplications.length,
    );

    // You can pass dailyProgress.completedZekr / dailyProgress.totalZekr
    // (or dailyProgress.totalRepsRead) directly into GradientCard once you add
    // a progress badge/bar to it. For now, it displays cleanly in the subtitle:
    final progressText = dailyProgress.completedZekr > 0
        ? '${dailyProgress.completedZekr}/${dailyProgress.totalZekr} مكتمل'
        : card.subtitle;

    return Expanded(
      child: GradientCard(
        palette: card.palette,
        title: card.title,
        subtitle: progressText,
        icon: card.icon,
        iconPath: card.iconPath,
        onTap: () async {
          final readInSession = await Navigator.push<int>(
            context,
            MaterialPageRoute(
              builder: (context) => AzkarPage(
                allSupplications: supplications,
                title: card.title,
                duaTime: card.duaTime,
              ),
            ),
          );

          if (!mounted) return;
          setState(() {}); // Refresh cards with today's updated progress

          if (readInSession != null && readInSession > 0) {
            ScaffoldMessenger.of(this.context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    spacing: 10,
                    children: [
                      const Icon(
                        Icons.bookmark_added_rounded,
                        color: AppColors.primary,
                      ),
                      Expanded(
                        child: Text(
                          'أحسنت! قرأت $readInSession ذكر وتم حفظ تقدمك',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.darkGreenNavBarBG,
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        spacing: 16,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                _buildCard(context, azkarCards[0]),
                _buildCard(context, azkarCards[1]),
              ],
            ),
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                _buildCard(context, azkarCards[2]),
                _buildCard(context, azkarCards[3]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
