import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_azkar/data/models/dua_model.dart';
import 'package:project_azkar/utils/enums.dart';

import '../../../services/azkar_cache_service.dart';
import '../../azkar/models/saved_zekr_entry.dart';

part 'azkar_state.dart';

class AzkarCubit extends Cubit<AzkarState> {
  final DuaTime duaTime;

  AzkarCubit({
    required List<DuaModel> initialSupplications,
    required this.duaTime,
  }) : super(_hydrateInitialState(initialSupplications, duaTime));

  static AzkarState _hydrateInitialState(
    List<DuaModel> supplications,
    DuaTime duaTime,
  ) {
    final saved = AzkarCacheService.getDailyProgress(
      duaTime,
      supplications.length,
    );
    final hasMatchingCache = saved.entries.length == supplications.length;

    final items = List<ZekrStateItem>.generate(supplications.length, (i) {
      final dua = supplications[i];
      if (hasMatchingCache) {
        final entry = saved.entries[i];
        return ZekrStateItem(
          supplication: dua,
          targetCount: dua.count,
          // Uncompleted zekrs always start fresh at full count
          currentCount: entry.isCompleted ? 0 : dua.count,
          isCompleted: entry.isCompleted,
          readReps: entry.readReps,
          recountRemaining: dua.count,
        );
      }
      return ZekrStateItem(
        supplication: dua,
        targetCount: dua.count,
        currentCount: dua.count,
        isCompleted: false,
        readReps: 0,
        recountRemaining: dua.count,
      );
    });

    return AzkarState(items: items);
  }

  Future<void> _persist(
    List<ZekrStateItem> items, {
    int lifetimeDelta = 0,
  }) async {
    final entries = items
        .map(
          (e) =>
              SavedZekrEntry(isCompleted: e.isCompleted, readReps: e.readReps),
        )
        .toList();

    await AzkarCacheService.cacheDailyProgress(
      duaTime: duaTime,
      entries: entries,
    );

    if (lifetimeDelta != 0) {
      await AzkarCacheService.addToLifetimeAzkarCount(lifetimeDelta);
    }
  }

  void skipZekr(DuaModel supplication) {
    int skippedReps = 0;

    final updatedItems = state.items.map((item) {
      if (item.supplication == supplication && !item.isCompleted) {
        skippedReps = item.targetCount;
        return item.copyWith(
          currentCount: 0,
          isCompleted: true,
          readReps: item.readReps + item.targetCount,
          recountRemaining: item.targetCount,
        );
      }
      return item;
    }).toList();

    if (skippedReps == 0) return;

    emit(
      state.copyWith(
        items: updatedItems,
        sessionRepsRead: state.sessionRepsRead + skippedReps,
      ),
    );
    _persist(updatedItems, lifetimeDelta: skippedReps);
  }

  void decrementCount(DuaModel supplication) {
    bool didChange = false;
    int completedReps = 0;

    final updatedItems = state.items.map((item) {
      if (item.supplication == supplication &&
          !item.isCompleted &&
          item.currentCount > 0) {
        didChange = true;
        final nextCount = item.currentCount - 1;
        final done = nextCount == 0;

        if (done) {
          completedReps = item.targetCount;
        }

        return item.copyWith(
          currentCount: nextCount,
          isCompleted: done,
          readReps: done ? item.readReps + item.targetCount : item.readReps,
          recountRemaining: done ? item.targetCount : item.recountRemaining,
        );
      }
      return item;
    }).toList();

    if (!didChange) return;

    emit(
      state.copyWith(
        items: updatedItems,
        sessionRepsRead: state.sessionRepsRead + completedReps,
      ),
    );

    // Only persist and add to lifetime total once the whole zekr is finished
    if (completedReps > 0) {
      _persist(updatedItems, lifetimeDelta: completedReps);
    }
  }

  bool decrementSingleCount(int index) {
    if (index < 0 || index >= state.items.length) return false;
    final item = state.items[index];

    bool hitZero = false;
    int completedReps = 0;
    late final ZekrStateItem updatedItem;

    if (!item.isCompleted) {
      final nextCount = (item.currentCount - 1).clamp(0, item.targetCount);
      final done = nextCount == 0;
      hitZero = done;

      if (done) {
        completedReps = item.targetCount;
      }

      updatedItem = item.copyWith(
        currentCount: nextCount,
        isCompleted: done,
        readReps: done ? item.readReps + item.targetCount : item.readReps,
        recountRemaining: done ? 0 : item.recountRemaining,
      );
    } else {
      // Already completed: allow recounting in Single without adding reps
      final base = item.recountRemaining == 0
          ? item.targetCount
          : item.recountRemaining;
      final nextRecount = (base - 1).clamp(0, item.targetCount);
      hitZero = nextRecount == 0;
      updatedItem = item.copyWith(recountRemaining: nextRecount);
    }

    final updatedItems = List<ZekrStateItem>.from(state.items);
    updatedItems[index] = updatedItem;

    emit(
      state.copyWith(
        items: updatedItems,
        sessionRepsRead: state.sessionRepsRead + completedReps,
      ),
    );

    if (completedReps > 0) {
      _persist(updatedItems, lifetimeDelta: completedReps);
    }
    return hitZero;
  }

  void resetRecount(int index) {
    if (index < 0 || index >= state.items.length) return;
    final item = state.items[index];
    if (!item.isCompleted || item.recountRemaining == item.targetCount) return;

    final updatedItems = List<ZekrStateItem>.from(state.items);
    updatedItems[index] = item.copyWith(recountRemaining: item.targetCount);
    emit(state.copyWith(items: updatedItems));
  }

  void undoCount(DuaModel supplication) {
    bool didUndo = false;
    final updatedItems = state.items.map((item) {
      if (item.supplication == supplication &&
          (item.isCompleted || item.currentCount != item.targetCount)) {
        didUndo = true;
        return item.copyWith(
          currentCount: item.targetCount,
          isCompleted: false,
          recountRemaining: item.targetCount,
          // Keep readReps intact (do not decrement counted or lifetime reps)
        );
      }
      return item;
    }).toList();

    if (!didUndo) return;
    emit(state.copyWith(items: updatedItems));
    // Persist the uncompleted status in daily progress; lifetimeDelta stays 0
    _persist(updatedItems);
  }

  void restoreAllRead() {
    final hasAnythingToReset = state.items.any(
      (item) => item.isCompleted || item.currentCount != item.targetCount,
    );
    if (!hasAnythingToReset) return;

    final updatedItems = state.items
        .map(
          (item) => item.copyWith(
            currentCount: item.targetCount,
            isCompleted: false,
            recountRemaining: item.targetCount,
          ),
        )
        .toList();

    emit(state.copyWith(items: updatedItems, showReadList: false));
    _persist(updatedItems); // lifetimeDelta stays 0
  }

  void toggleList(bool showRead) {
    emit(state.copyWith(showReadList: showRead));
  }
}
