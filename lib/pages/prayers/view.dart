import 'package:flutter/material.dart';

import 'widgets/carousel_prayers.dart';
import 'widgets/prayers_grid.dart';

class PrayersPage extends StatelessWidget {
  const PrayersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Top section wrapped in SliverToBoxAdapter
        SliverToBoxAdapter(
          child: Column(
            spacing: 18,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'الأكثر تكرارا',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const CarouselPrayers(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'القائمة الكاملة',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(
                height: 0,
              ), // Ensures spacing applies before the grid
            ],
          ),
        ),
        // The Grid section (now a Sliver)
        const PrayersGrid(),

        // Optional: Add bottom padding so the grid doesn't hug the bottom edge of the screen
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
