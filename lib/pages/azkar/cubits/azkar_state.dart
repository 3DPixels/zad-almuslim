part of 'azkar_cubit.dart';

class ZekrStateItem {
  final DuaModel supplication;
  final int targetCount;
  final int currentCount;
  final bool isCompleted;
  final int readReps;
  final int recountRemaining;

  const ZekrStateItem({
    required this.supplication,
    required this.targetCount,
    required this.currentCount,
    required this.isCompleted,
    required this.readReps,
    required this.recountRemaining,
  });

  bool get isRead => isCompleted;

  /// Count displayed on the counter button in AzkarSingle.
  int get singleDisplayCount => isCompleted ? recountRemaining : currentCount;

  ZekrStateItem copyWith({
    int? currentCount,
    bool? isCompleted,
    int? readReps,
    int? recountRemaining,
  }) {
    return ZekrStateItem(
      supplication: supplication,
      targetCount: targetCount,
      currentCount: currentCount ?? this.currentCount,
      isCompleted: isCompleted ?? this.isCompleted,
      readReps: readReps ?? this.readReps,
      recountRemaining: recountRemaining ?? this.recountRemaining,
    );
  }
}

class AzkarState {
  final List<ZekrStateItem> items;
  final bool showReadList;

  /// Reps from zekrs completed during this visit (used for the exit SnackBar
  /// and the CompletionPage ReelText roll-up delta).
  final int sessionRepsRead;

  const AzkarState({
    required this.items,
    this.showReadList = false,
    this.sessionRepsRead = 0,
  });

  List<ZekrStateItem> get unreadItems => items.where((e) => !e.isRead).toList();
  List<ZekrStateItem> get readItems => items.where((e) => e.isRead).toList();

  int get totalZekr => items.length;
  int get completedZekr => readItems.length;
  double get progress => totalZekr == 0 ? 0 : completedZekr / totalZekr;

  /// Total reps for this entire azkar category (shown on CompletionPage).
  int get totalCategoryReps =>
      items.fold(0, (sum, item) => sum + item.targetCount);

  /// Total reps actually completed today for this category.
  int get totalRepsRead => items.fold(0, (sum, item) => sum + item.readReps);

  AzkarState copyWith({
    List<ZekrStateItem>? items,
    bool? showReadList,
    int? sessionRepsRead,
  }) {
    return AzkarState(
      items: items ?? this.items,
      showReadList: showReadList ?? this.showReadList,
      sessionRepsRead: sessionRepsRead ?? this.sessionRepsRead,
    );
  }
}
