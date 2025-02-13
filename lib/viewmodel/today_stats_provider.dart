import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/task_database.dart';
import '../extensions.dart';

final todayStatsProvider =
    StateNotifierProvider<TodayStatsNotifier, AsyncValue<Map<String, int>>>(
        (ref) {
  return TodayStatsNotifier();
});

class TodayStatsNotifier extends StateNotifier<AsyncValue<Map<String, int>>> {
  TodayStatsNotifier() : super(const AsyncValue.loading()) {
    fetchTodayStats();
  }

  final TaskDatabase _db = TaskDatabase();

  Future<void> fetchTodayStats() async {
    try {
      final today = DateTime.now();
      final tasks = await _db.fetchTasks();

      final totalTasks =
          tasks.where((task) => task.dueDate.isSameDate(today)).length;
      final pendingTasks = tasks
          .where((task) => task.dueDate.isSameDate(today) && !task.isCompleted)
          .length;
      final completedTasks = tasks
          .where((task) => task.dueDate.isSameDate(today) && task.isCompleted)
          .length;

      final todayStats = {
        "total": totalTasks,
        "pending": pendingTasks,
        "completed": completedTasks,
      };

      // Update the state with today's statistics
      state = AsyncValue.data(todayStats);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
