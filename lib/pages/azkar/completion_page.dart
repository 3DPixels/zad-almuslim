import 'package:flutter/material.dart';
import 'package:project_azkar/services/azkar_cache_service.dart';
import 'package:reel_text/reel_text.dart';

import '../../extensions/num_extension.dart';
import '../../utils/app_colors.dart';

class CompletionPage extends StatefulWidget {
  /// Total reps for this azkar category.
  final int totalRead;

  /// Reps completed during this visit, used only to animate the lifetime
  /// ReelText roll-up without re-writing cache.
  final int addedInSession;

  const CompletionPage({
    super.key,
    required this.totalRead,
    this.addedInSession = 0,
  });

  @override
  State<CompletionPage> createState() => _CompletionPageState();
}

class _CompletionPageState extends State<CompletionPage> {
  late int globalCount;
  late final int _targetLifetimeTotal;

  @override
  void initState() {
    super.initState();
    // Lifetime total is already persisted by AzkarCubit as each zekr finishes
    _targetLifetimeTotal = AzkarCacheService.getLifetimeAzkarCount();

    // Start ReelText at the pre-session lifetime count so it animates upward
    globalCount = (_targetLifetimeTotal - widget.addedInSession).clamp(
      0,
      _targetLifetimeTotal,
    );

    if (globalCount < _targetLifetimeTotal) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            globalCount = _targetLifetimeTotal;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'تقبل الله!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'أتممت ${widget.totalRead.toArabic()} من الأذكار',
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'مجموع أذكارك الكلي: ',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ReelText(
                  globalCount.toArabic(),
                  options: const ReelTextOptions(
                    duration: Duration(milliseconds: 500),
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    );
  }
}
