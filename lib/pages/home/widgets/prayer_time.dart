import 'package:flutter/material.dart';

class PrayerTime extends StatelessWidget {
  final bool passed;
  final bool currentPrayer;
  final String prayer;
  final String prayerTime;
  const PrayerTime({
    super.key,
    required this.passed,
    required this.prayer,
    required this.prayerTime,
    this.currentPrayer = false,
  });

  @override
  Widget build(BuildContext context) {
    // Scale avatar and icon proportionally with the text size
    final scaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 1.0, maxScaleFactor: 1.35);

    return Column(
      spacing: 5,
      children: [
        CircleAvatar(
          radius: scaler.scale(20),
          backgroundColor: !currentPrayer
              ? Colors.transparent
              : Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          child: Icon(
            size: scaler.scale(24),
            currentPrayer
                ? Icons.access_time_filled
                : passed
                ? Icons.check_circle
                : Icons.access_time,
          ),
        ),
        Text(
          prayer,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: currentPrayer ? FontWeight.bold : null,
          ),
        ),
        Text(
          prayerTime,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: currentPrayer ? FontWeight.bold : null,
          ),
        ),
      ],
    );
  }
}
