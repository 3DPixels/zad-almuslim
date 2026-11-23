import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/models/dua_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../widgets/dua_details_sheet.dart';

class AzkarSingleCard extends StatelessWidget {
  final DuaModel supplication;
  final bool isCompleted;
  final int cardNumber;
  final int totalCards;

  const AzkarSingleCard({
    super.key,
    required this.supplication,
    required this.isCompleted,
    required this.cardNumber,
    required this.totalCards,
  });

  static const _iconsColor = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    final duaStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontFamily: AppFonts.notoSans,
      height: 1.7,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkGreenSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isCompleted ? 0.45 : 0.15),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: _AutoShrinkText(
                      supplication.dua,
                      style:
                          duaStyle ??
                          const TextStyle(fontSize: 22, height: 1.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    thickness: 1,
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 12),
                  if (supplication.benefit.isNotEmpty)
                    Text(
                      supplication.benefit,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _iconsColor,
                        height: 1.6,
                      ),
                    ),
                  if (supplication.source.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: AppColors.darkGreenSurface,
                          showDragHandle: true,
                          isScrollControlled: true,
                          builder: (context) => DuaDetailsSheet(
                            source: supplication.source,
                            benefit:
                                supplication.benefitSource ??
                                supplication.benefit,
                            buttonsColor: AppColors.primary,
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        textStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              fontFamily: AppFonts.notoSans,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      label: Text(supplication.source),
                      icon: const Icon(Icons.menu_book, size: 18),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Toolbar (Copy, Share + Status / Card Number)
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkGreenNavBarBG,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              border: BorderDirectional(
                top: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'نسخ',
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: supplication.dua),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              spacing: 10,
                              children: [
                                Icon(Icons.copy_rounded),
                                Text(
                                  'تم نسخ الدعاء',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.darkGreenNavBarBG,
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded),
                      color: _iconsColor,
                    ),
                    IconButton(
                      tooltip: 'مشاركة',
                      onPressed: () {
                        final textToShare =
                            '\u200F${supplication.dua} - ${supplication.benefit}';
                        SharePlus.instance.share(
                          ShareParams(title: 'Dua share', text: textToShare),
                        );
                      },
                      icon: const Icon(Icons.share),
                      color: _iconsColor,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    spacing: 8,
                    children: [
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            spacing: 4,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              Text(
                                'مقروء',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        '$cardNumber / $totalCards',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: _iconsColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoShrinkText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final double minFontSize;

  const _AutoShrinkText(this.text, {required this.style})
    : minFontSize = 12,
      textAlign = TextAlign.center;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final baseFontSize = style.fontSize ?? 22.0;
        final textDirection = Directionality.of(context);
        final textScaler = MediaQuery.textScalerOf(context);

        bool fits(double fontSize) {
          final painter = TextPainter(
            text: TextSpan(
              text: text,
              style: style.copyWith(fontSize: fontSize),
            ),
            textAlign: textAlign,
            textDirection: textDirection,
            textScaler: textScaler,
          )..layout(maxWidth: constraints.maxWidth);
          return painter.height <= constraints.maxHeight;
        }

        double chosenSize = baseFontSize;
        bool stillOverflows = false;

        if (constraints.maxHeight.isFinite && !fits(baseFontSize)) {
          if (!fits(minFontSize)) {
            chosenSize = minFontSize;
            stillOverflows = true;
          } else {
            double low = minFontSize;
            double high = baseFontSize;
            while ((high - low) > 0.5) {
              final mid = (low + high) / 2;
              if (fits(mid)) {
                low = mid;
              } else {
                high = mid;
              }
            }
            chosenSize = low;
          }
        }

        final textWidget = Text(
          text,
          textAlign: textAlign,
          style: style.copyWith(fontSize: chosenSize),
        );

        return stillOverflows
            ? SingleChildScrollView(child: textWidget)
            : textWidget;
      },
    );
  }
}
