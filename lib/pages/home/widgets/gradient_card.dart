import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../data/models/card_pallete_model.dart';

class GradientCard extends StatelessWidget {
  final CardPalette palette;
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? iconPath;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.palette,
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Read the globally scaled icon size from main.dart's IconTheme!
    final double globalIconSize = IconTheme.of(context).size ?? 24.0;
    final double iconPadding = MediaQuery.textScalerOf(context).scale(10.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Keeps the nice card height at default font size, but allows it to grow taller if needed
        constraints: const BoxConstraints(minHeight: 135),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: RadialGradient(
            center: const Alignment(0.6, -0.6),
            radius: .7,
            colors: [
              palette.gradientColor,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Pushes the icon to the top and the text to the bottom without overflowing
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 12,
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: palette.glowColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: icon != null
                  // Uses global IconTheme size automatically!
                  ? Icon(icon, color: palette.iconColor)
                  : SvgPicture.asset(
                      iconPath!,
                      width: globalIconSize,
                      height: globalIconSize,
                    ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
