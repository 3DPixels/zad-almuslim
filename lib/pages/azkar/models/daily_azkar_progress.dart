import 'saved_zekr_entry.dart';

class DailyAzkarProgress {
  final int completedZekr;
  final int totalZekr;
  final int totalRepsRead;
  final List<SavedZekrEntry> entries;

  const DailyAzkarProgress({
    required this.completedZekr,
    required this.totalZekr,
    required this.totalRepsRead,
    required this.entries,
  });

  double get progress => totalZekr == 0 ? 0.0 : completedZekr / totalZekr;
}
