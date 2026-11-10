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
    return Column(
      spacing: 5,
      children: [
        CircleAvatar(
          backgroundColor: !currentPrayer
              ? Colors.transparent
              : Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          child: Icon(
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
