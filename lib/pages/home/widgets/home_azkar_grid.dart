import 'package:flutter/material.dart';
import 'package:project_azkar/data/repos/zekr_repo.dart';
import 'package:project_azkar/pages/supplications/azkar/azkar_page.dart';
import 'package:project_azkar/utils/app_icons.dart';
import 'package:project_azkar/utils/enums.dart';

import '../../../data/models/card_pallete_model.dart';
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

class HomeAzkarGrid extends StatelessWidget {
  const HomeAzkarGrid({super.key});

  Widget _buildCard(BuildContext context, AzkarCardData card) {
    return Expanded(
      child: GradientCard(
        palette: card.palette,
        title: card.title,
        subtitle: card.subtitle,
        icon: card.icon,
        iconPath: card.iconPath,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AzkarPage(
                allSupplications: ZekrRepo.getAzkarByTime(card.duaTime),
                title: card.title,
              ),
            ),
          );
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
          // First Row (Morning & Evening Azkar)
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
          // Second Row (After Prayer & Before Sleep Azkar)
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
