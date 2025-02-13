import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/task_database.dart';
import '../enum.dart';
import '../models/task_model.dart';
import '../services/notification_service.dart';



// Main Task Provider
final taskProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  return TaskNotifier();
});

final searchQueryProvider = StateProvider<String>((ref) => "");
final filterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  TaskNotifier() : super(const AsyncValue.loading()) {
    loadTasks(); // Fetch today's stats once
  }

  final TaskDatabase _db = TaskDatabase();
  final Map<String, List<Task>> _tasksByDate = {};
  List<Task> _allTasks = [];

  Future<void> loadTasks() async {
    try {
      state = const AsyncValue.loading();
      _allTasks = await _db.fetchTasks();
      _groupTasksByDate();
      state = AsyncValue.data(_allTasks);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  void _groupTasksByDate() {
    _tasksByDate.clear();
    for (var task in _allTasks) {
      String dateKey = DateFormat('yyyy-MM-dd').format(task.dueDate);
      if (_tasksByDate.containsKey(dateKey)) {
        _tasksByDate[dateKey]!.add(task);
      } else {
        _tasksByDate[dateKey] = [task];
      }
    }
  }

  void applyFiltersAndSearch(String query, TaskFilter filter, {DateTime? date}) {
    List<Task> filteredTasks = _allTasks;

    if (date != null) {
      String dateKey = DateFormat('yyyy-MM-dd').format(date);
      filteredTasks = _tasksByDate[dateKey] ?? [];
    }

    if (query.isNotEmpty) {
      filteredTasks = filteredTasks
          .where((task) => task.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    switch (filter) {
      case TaskFilter.completed:
        filteredTasks = filteredTasks.where((task) => task.isCompleted).toList();
        break;
      case TaskFilter.pending:
        filteredTasks = filteredTasks.where((task) => !task.isCompleted).toList();
        break;
      case TaskFilter.basic:
        filteredTasks = filteredTasks.where((task) => task.priority == 'Basic').toList();
        break;
      case TaskFilter.urgent:
        filteredTasks = filteredTasks.where((task) => task.priority == 'Urgent').toList();
        break;
      case TaskFilter.important:
        filteredTasks = filteredTasks.where((task) => task.priority == 'Important').toList();
        break;
      case TaskFilter.all:
      // No filtering needed, keep all tasks
        break;
    }

    state = AsyncValue.data(filteredTasks);
  }


  Future<void> addTask(Task task) async {
    final id = await _db.insertTask(task);
    await NotificationService.showNotification(id, task.title, "Task is due!", task.dueDate);
    loadTasks();
  }

  Future<void> updateTask(Task updatedTask) async {
    await _db.updateTask(updatedTask);
    await NotificationService.cancelNotification(updatedTask.id!);
    await NotificationService.showNotification(
        updatedTask.id!, updatedTask.title, "Task updated!", updatedTask.dueDate);
    loadTasks();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    Task updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updatedTask);
  }

  Future<void> deleteTask(int id) async {
    await _db.deleteTask(id);
    await NotificationService.cancelNotification(id);
    loadTasks();
  }

  Future<void> fetchTasksForDate(DateTime date) async {
    String dateKey = DateFormat('yyyy-MM-dd').format(date);
    List<Task> tasksForDate = _tasksByDate[dateKey] ?? [];
    state = AsyncValue.data(tasksForDate);
  }
}
