import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:project_azkar/utils/app_fonts.dart';
import 'package:project_azkar/widgets/dua_details_sheet.dart';
import 'package:share_plus/share_plus.dart';

import '../data/models/dua_model.dart';
import '../utils/app_colors.dart';

class DuaCard extends StatefulWidget {
  final DuaModel supplication;
  final Color buttonsColor;
  final Color borderColor;
  final Color bottomColor;
  final Color containerBackgroundColor;
  final int? duaIndex;

  // Optional parameters for counting functionality
  final bool enableCounter;
  final int currentCount;
  final int targetCount;
  final VoidCallback? onTap;
  final VoidCallback? onUndo;
  final VoidCallback? onSkip;

  const DuaCard({
    super.key,
    required this.supplication,
    required this.buttonsColor,
    required this.borderColor,
    required this.bottomColor,
    required this.containerBackgroundColor,
    this.duaIndex,
    this.enableCounter = false,
    this.currentCount = 0,
    this.targetCount = 0,
    this.onTap,
    this.onUndo,
    this.onSkip,
  });

  @override
  State<DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends State<DuaCard> {
  bool isPlaying = false;
  bool isFading = false;
  bool isCollapsed = false;

  // New variables for the Hold-to-Skip feature
  bool isLongPressing = false;
  Timer? _holdTimer;

  final iconsColor = const Color(0xFF94A3B8);
  final fadeDuration = const Duration(milliseconds: 200);
  final sizeDuration = const Duration(milliseconds: 250);

  // --- Normal Tap Logic (Kept EXACTLY the same) ---
  void _handleTap() async {
    if (widget.currentCount == 1) {
      HapticFeedback.mediumImpact();
      setState(() {
        isFading = true;
      });
      await Future.delayed(fadeDuration);
      if (!mounted) return;

      setState(() {
        isCollapsed = true;
      });
      await Future.delayed(sizeDuration);
      if (!mounted) return;

      widget.onTap?.call();
    } else {
      HapticFeedback.selectionClick();
      widget.onTap?.call();
    }
  }

  void _handleUndo() async {
    setState(() {
      isFading = true;
    });
    await Future.delayed(fadeDuration);
    if (!mounted) return;

    setState(() {
      isCollapsed = true;
    });
    await Future.delayed(sizeDuration);
    if (!mounted) return;

    widget.onUndo?.call();
  }

  // --- Hold-to-Skip Logic ---
  void _startLongPress() {
    // 1. Initial vibration when the half-second hold is registered
    HapticFeedback.selectionClick();

    // 2. Trigger the flutter_animate scale and shake
    setState(() {
      isLongPressing = true;
    });

    // 3. Start a timer matching the animation duration (500ms)
    _holdTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      // 4. If they held it the whole time, trigger heavy vibration and skip!
      HapticFeedback.heavyImpact();
      _handleSkip();
    });
  }

  void _cancelLongPress() {
    // If user lets go early, cancel the timer and reset the scale/shake
    _holdTimer?.cancel();
    if (isLongPressing) {
      setState(() {
        isLongPressing = false;
      });
    }
  }

  void _handleSkip() async {
    // Stop scaling, immediately start fading
    setState(() {
      isLongPressing = false;
      isFading = true;
    });

    await Future.delayed(fadeDuration);
    if (!mounted) return;

    setState(() {
      isCollapsed = true;
    });
    await Future.delayed(sizeDuration);
    if (!mounted) return;

    widget.onSkip?.call(); // Triggers the Cubit to force 0
  }

  @override
  Widget build(BuildContext context) {
    final bool canTap = widget.enableCounter && widget.currentCount > 0;

    return AnimatedSize(
      duration: sizeDuration,
      curve: Curves.easeInOut,
      child: isCollapsed
          ? const SizedBox(width: double.infinity, height: 0)
          : AnimatedOpacity(
              duration: fadeDuration,
              opacity: isFading ? 0 : 1,
              curve: Curves.easeInOut,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: canTap ? _handleTap : null,
                  onLongPress: canTap ? _startLongPress : null,
                  onLongPressUp: canTap ? _cancelLongPress : null,
                  onLongPressCancel: canTap ? _cancelLongPress : null,
                  child:
                      Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: BoxBorder.all(color: widget.borderColor),
                              color: widget.containerBackgroundColor,
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    spacing: 16,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Play button
                                      // IconButton.filled(
                                      //   onPressed: () {
                                      //     setState(() {
                                      //       isPlaying = !isPlaying;
                                      //     });
                                      //   },
                                      //   iconSize: 35,
                                      //   style: IconButton.styleFrom(
                                      //     backgroundColor: widget.buttonsColor
                                      //         .withValues(alpha: .1),
                                      //     foregroundColor: widget.buttonsColor,
                                      //   ),
                                      //   icon: Icon(
                                      //     isPlaying
                                      //         ? Icons.pause
                                      //         : Icons.play_arrow_outlined,
                                      //   ),
                                      // ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 10,
                                          children: [
                                            Text(
                                              widget.supplication.dua,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontFamily:
                                                        AppFonts.notoSans,
                                                  ),
                                            ),
                                            if (!(widget
                                                    .supplication
                                                    .benefit
                                                    .isEmpty &&
                                                widget
                                                    .supplication
                                                    .source
                                                    .isEmpty))
                                              Divider(
                                                thickness: 1,
                                                color: widget.borderColor,
                                              ),
                                            if (widget
                                                .supplication
                                                .benefit
                                                .isNotEmpty)
                                              Text(
                                                widget.supplication.benefit,
                                                maxLines: 3,
                                                overflow: .ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      color: iconsColor,
                                                    ),
                                              ),
                                            if (widget
                                                .supplication
                                                .source
                                                .isNotEmpty)
                                              TextButton.icon(
                                                onPressed: () {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    backgroundColor: widget
                                                        .containerBackgroundColor,
                                                    showDragHandle: true,
                                                    isScrollControlled: true,
                                                    builder: (context) =>
                                                        DuaDetailsSheet(
                                                          source: widget
                                                              .supplication
                                                              .source,
                                                          benefit:
                                                              widget
                                                                  .supplication
                                                                  .benefitSource ??
                                                              widget
                                                                  .supplication
                                                                  .benefit,
                                                          buttonsColor: widget
                                                              .buttonsColor,
                                                        ),
                                                  );
                                                },
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      widget.buttonsColor,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontFamily:
                                                            AppFonts.notoSans,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                                label: Text(
                                                  widget.supplication.source,
                                                ),
                                                icon: const Icon(
                                                  Icons.menu_book,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Bottom container
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(24),
                                    ),
                                    border: BorderDirectional(
                                      top: BorderSide(
                                        color: widget.borderColor,
                                      ),
                                    ),
                                    color: widget.bottomColor,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      // IconButton(
                                      //   onPressed: () {},
                                      //   icon: const Icon(Icons.favorite_border),
                                      //   color: iconsColor,
                                      // ),
                                      IconButton(
                                        onPressed: () async {
                                          await Clipboard.setData(
                                            ClipboardData(
                                              text: widget.supplication.dua,
                                            ),
                                          );
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Row(
                                                spacing: 10,
                                                children: [
                                                  Icon(Icons.copy_rounded),
                                                  Text(
                                                    "تم نسخ الدعاء",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor:
                                                  AppColors.darkGreenNavBarBG,
                                              duration: Duration(seconds: 3),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.copy_rounded),
                                        color: iconsColor,
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          String originalText =
                                              '${widget.supplication.dua} - ${widget.supplication.benefit}';
                                          // \u200F is the Unicode Right-to-Left Mark
                                          // It forces the receiving app's text editor to treat the string as RTL
                                          String textToShare =
                                              '\u200F$originalText';
                                          SharePlus.instance.share(
                                            ShareParams(
                                              title: 'Dua share',
                                              text: textToShare,
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.share),
                                        color: iconsColor,
                                      ),
                                      const Spacer(),

                                      // The 3 States Logic
                                      if (!widget.enableCounter)
                                        // State 1: Counter disabled (Standard view for rest of app)
                                        Text(
                                          'Dua #${widget.duaIndex ?? 1}',
                                          style: TextStyle(
                                            color: iconsColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        )
                                      else if (widget.currentCount == 0)
                                        // State 3: Counter enabled, but count is 0 (Show Undo)
                                        TextButton.icon(
                                          onPressed: _handleUndo,
                                          icon: const Icon(Icons.undo),
                                          label: const Text('تراجع'),
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                widget.buttonsColor,
                                          ),
                                        )
                                      else
                                        // State 2: Counter enabled, count > 0 (Show Progress)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: widget.buttonsColor
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            '${widget.currentCount} / ${widget.targetCount}',
                                            style: TextStyle(
                                              color: widget.buttonsColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate(target: isLongPressing ? 1 : 0)
                          .scale(
                            end: const Offset(1.05, 1.05),
                            duration: 500.ms,
                            curve: Curves.easeOut,
                          )
                          .shake(
                            hz: 5,
                            offset: Offset(3, 3),
                            rotation: 0.01, // Adds a slight tilt to the shake
                            duration: 500.ms,
                          ),
                ),
              ),
            ),
    );
  }
}
