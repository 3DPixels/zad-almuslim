import 'package:flutter/material.dart';
import 'package:project_azkar/pages/prayers/models/prayer_model.dart';

import '../../extensions/num_extension.dart';
import '../../utils/app_fonts.dart';

class PrayerDetails extends StatefulWidget {
  final PrayerModel prayer;
  const PrayerDetails(this.prayer, {super.key});

  @override
  State<PrayerDetails> createState() => _PrayerDetailsState();
}

class _PrayerDetailsState extends State<PrayerDetails> {
  late ScrollController _scrollController;
  bool _isCollapsed = false;
  final double _expandedHeight = 280.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.hasClients) {
          bool isCollapsed =
              _scrollController.offset >
              (_expandedHeight - kToolbarHeight - 30);
          if (_isCollapsed != isCollapsed) {
            setState(() => _isCollapsed = isCollapsed);
          }
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.prayer.prayerSteps;
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: _expandedHeight,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF101010),
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isCollapsed ? 1.0 : 0.0,
              child: Text(
                'كيفية ${widget.prayer.title}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.blurBackground,
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(widget.prayer.imagePath, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                          const Color(0xFF101010),
                        ],
                        stops: const [0.3, 0.8, 1.0],
                      ),
                    ),
                  ),
                  // Header Content Container
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tags Row
                        Row(
                          children: [
                            if (widget.prayer.chipText != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF425A38),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.prayer.chipText!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (widget.prayer.hintText != null) ...[
                              const Icon(
                                Icons.access_time,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.prayer.hintText!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.prayer.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.prayer.subtitle,
                          style: TextStyle(
                            color: Color(0xFFB0B0B0),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section Header (Steps)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'خطوات العبادة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2C3E21)),
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF161F12),
                    ),
                    child: Text(
                      '${steps.length.toArabic()} خطوات',
                      style: TextStyle(color: Color(0xFF7A9F63), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stepper List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final step = steps[index];
                return StepTile(
                  index: index,
                  isLast: index == steps.length - 1,
                  title: step.title,
                  subtitle: step.subtitle,
                  innerText: step.desc,
                );
              }, childCount: steps.length),
            ),
          ),

          if (widget.prayer.importantStep != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF262626)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      Text(
                        widget.prayer.importantStep!.title,
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(color: Color(0xFF586C42)),
                      ),

                      Text(
                        widget.prayer.importantStep!.subtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(height: 2, fontFamily: AppFonts.notoSans),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (widget.prayer.info != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF536C41).withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF536C41).withValues(alpha: .2),
                      // width: .5,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: .start,
                    spacing: 10,
                    children: [
                      Icon(Icons.info, color: Color(0xFF536C41), size: 22),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 5,
                          children: [
                            Text(
                              'ملاحظة هامة',
                              style: TextStyle(fontSize: 14, fontWeight: .bold),
                            ),
                            Text(
                              widget.prayer.info!,

                              style: const TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class StepTile extends StatelessWidget {
  final int index;
  final bool isLast;
  final String title;
  final String subtitle;
  final String? innerText;

  const StepTile({
    super.key,
    required this.index,
    required this.isLast,
    required this.title,
    required this.subtitle,
    required this.innerText,
  });

  @override
  Widget build(BuildContext context) {
    const lineColor = Color(0xFF596D42);
    const greenBorderColor = Color(0xFF596D42);
    const numberColor = Color(0xFF596D42);

    return IntrinsicHeight(
      child: Row(
        spacing: 16,
        children: [
          // 1. Timeline Indicator Column
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: greenBorderColor, width: 1.5),
                  color: const Color(0xFF1A1A1A),
                ),
                alignment: Alignment.center,
                child: Text(
                  (index + 1).toArabic(),
                  style: const TextStyle(
                    color: numberColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    gradient: isLast
                        ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [lineColor, Colors.transparent],
                          )
                        : null,
                    color: isLast ? null : lineColor,
                  ),
                ),
              ),
            ],
          ),

          // 2. Step Card Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF262626)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 13,
                      ),
                    ),
                    if (innerText != null && innerText!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF242424),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          innerText!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontFamily: AppFonts.notoSans),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
