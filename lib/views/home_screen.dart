import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:task_management_app/extensions.dart';
import 'package:task_management_app/views/task_description_screen.dart';

import '../enum.dart';
import '../viewmodel/preferences_provider.dart';
import '../viewmodel/task_provider.dart';
import '../viewmodel/today_stats_provider.dart';
import 'add_task_screen.dart';
import 'calendar_view/weekly_tab_controller.dart';
import 'calendar_view/weekly_tab_navigator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _searchController;
  late TaskFilter _filter;
  late DateTime startDate;
  late WeeklyTabController controller;
  late DateTime selectedDate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filter = TaskFilter.all;
    startDate = WeeklyTabNavigator.calcSafeDate(DateTime.now());
    controller = WeeklyTabController(position: startDate);
    selectedDate = startDate;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Refresh Today's Stats
  void refreshTodayStats(WidgetRef ref) {
    final tasks = ref.read(taskProvider);

    tasks.whenData((data) {
      if (data.any((task) => task.dueDate.isSameDate(DateTime.now()))) {
        // Only refresh if today's tasks are affected
        ref.read(todayStatsProvider.notifier).fetchTodayStats();
      }
    });
  }

  /// Apply Filters and Refresh Tasks
  Future<void> applyFiltersAndRefresh(WidgetRef ref) async {
    await Future.delayed(Duration(milliseconds: 300));
    ref.read(taskProvider.notifier).applyFiltersAndSearch(
          ref.read(searchQueryProvider),
          ref.read(filterProvider),
          date: selectedDate,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        refreshTodayStats(ref);
        applyFiltersAndRefresh(ref);

        final todayStats = ref.watch(todayStatsProvider);
        final prefs = ref.read(preferencesProvider.notifier);

        return Scaffold(
          appBar: AppBar(
            title: Text('Task Manager'),
            actions: [
              DropdownButton<TaskFilter>(
                value: _filter,
                onChanged: (newFilter) {
                  if (newFilter != null && newFilter != _filter) {
                    setState(() {
                      _filter = newFilter;
                    });
                    ref.read(filterProvider.notifier).state = newFilter;
                    applyFiltersAndRefresh(ref);
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: TaskFilter.all,
                    child: Text("All"),
                  ),
                  DropdownMenuItem(
                    value: TaskFilter.completed,
                    child: Text("Completed"),
                  ),
                  DropdownMenuItem(
                    value: TaskFilter.pending,
                    child: Text("Pending"),
                  ),
                  DropdownMenuItem(
                    value: TaskFilter.basic,
                    child: Text("Basic"),
                  ),
                  DropdownMenuItem(
                    value: TaskFilter.urgent,
                    child: Text("Urgent"),
                  ),
                  DropdownMenuItem(
                    value: TaskFilter.important,
                    child: Text("Important"),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.brightness_6),
                onPressed: () => prefs.toggleTheme(),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddTaskScreen(date: selectedDate),
                    ),
                  );
                  ref.read(todayStatsProvider.notifier).fetchTodayStats();
                  applyFiltersAndRefresh(ref);
                },
              ),
            ],
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : todayStats.when(
                  data: (stats) {
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You have ${stats["pending"]} tasks to complete',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Gap(15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: _TasksCounterContainer(
                                  icon: Icons.calendar_month,
                                  textTitle: 'Task Today',
                                  taskCount: '${stats["total"]} Tasks',
                                ),
                              ),
                              Gap(10),
                              Expanded(
                                child: _TasksCounterContainer(
                                  icon: Icons.bar_chart,
                                  textTitle: 'Tasks Completed',
                                  taskCount: '${stats["completed"]} tasks',
                                ),
                              ),
                            ],
                          ),
                          Gap(20),

                          // WeeklyTabNavigator with TaskListView
                          Expanded(
                            child: WeeklyTabNavigator(
                              controller: controller,
                              tabBuilder: (_, date) => _buildTab(date),
                              pageBuilder: (_, date) => TaskListView(date: date),
                              onTabChanged: (value) {
                                setState(() {
                                  selectedDate = value;
                                });
                                refreshTodayStats(ref);
                                applyFiltersAndRefresh(ref);
                              },
                              onPageChanged: (value) {
                                setState(() {
                                  selectedDate = value;
                                });
                                refreshTodayStats(ref);
                                applyFiltersAndRefresh(ref);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text("Error loading data")),
                ),
        );
      },
    );
  }
}

Widget _buildTab(DateTime date) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(DateFormat('EE').format(date).toUpperCase()),
      const SizedBox(width: 5),
      Text(date.day.toString()),
    ],
  );
}

class TaskListView extends ConsumerWidget {
  final DateTime date;

  const TaskListView({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return taskState.when(
      loading: () => Center(child: CircularProgressIndicator()),
      data: (tasks) {
        final filteredTasks = tasks.where((task) => task.isDueOn(date)).toList();

        if (filteredTasks.isEmpty) {
          return Center(
            child: Text(
              "No tasks found for this date.",
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskDescriptionScreen(task: task),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Color(0xFF2D2D2D) // Dark grey for dark mode
                      : Colors.purple.shade50, // Original light mode color
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Theme(
                              data: Theme.of(context).copyWith(
                                unselectedWidgetColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                              child: Checkbox(
                                value: task.isCompleted,
                                onChanged: (_) {
                                  ref.read(taskProvider.notifier).toggleTaskCompletion(task);
                                  ref.read(todayStatsProvider.notifier).fetchTodayStats();
                                },
                              ),
                            ),
                          ],
                        ),
                        Chip(
                          label: Text(
                            task.priority,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: _getPriorityColor(task.priority),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      error: (error, stack) => Center(
        child: Text(
          "Error: ${error.toString()}",
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _TasksCounterContainer extends StatelessWidget {
  final IconData icon;
  final String textTitle;
  final String taskCount;

  const _TasksCounterContainer({
    required this.icon,
    required this.textTitle,
    required this.taskCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white, // Darker background for dark mode
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.5)
                : Colors.grey.withOpacity(0.2), // Original light mode shadow
            spreadRadius: isDarkMode ? 1 : 2,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: isDarkMode
                ? Colors.grey.withOpacity(0.3)
                : Colors.purple.withOpacity(0.1), // Original light mode color
            radius: 25,
            child: Icon(
              icon,
              color: isDarkMode ? Colors.purple[200] : Colors.purple,
              size: 30,
            ),
          ),
          SizedBox(height: 10),
          Text(
            textTitle,
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 5),
          Text(
            taskCount,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}

Color _getPriorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case "urgent":
      return Colors.red;
    case "important":
      return Colors.orange;
    case "basic":
      return Colors.blue;
    default:
      return Colors.grey;
  }
}
