import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../colors.dart';
import '../models/task_model.dart';
import '../viewmodel/task_provider.dart';
import '../viewmodel/today_stats_provider.dart';
import 'edit_task_screen.dart';

class TaskDescriptionScreen extends ConsumerWidget {
  final Task task;

  const TaskDescriptionScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text(
          'Task Description',
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : AppColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditTaskScreen(task: task),
                ),
              );
            },
            icon: Icon(
              Icons.edit,
              color: isDarkMode ? Colors.blue[300] : AppColors.primaryBlue1,
            ),
            label: Text(
              'Edit Task',
              style: TextStyle(
                color: isDarkMode ? Colors.blue[300] : AppColors.primaryBlue1,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const Gap(10),
            Text(
              'Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const Gap(8),
            Text(
              task.description,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[300] : Colors.black54,
              ),
            ),
            const Gap(20),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: isDarkMode ? Colors.purpleAccent : Colors.purple,
                ),
                const Gap(8),
                Text(
                  'Due Date: ${DateFormat('dd MMM yyyy').format(task.dueDate)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey[300] : Colors.black54,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(taskProvider.notifier).deleteTask(task.id ?? 0);
                  ref.read(todayStatsProvider.notifier).fetchTodayStats();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? Colors.blue[700]
                      : AppColors.primaryBlue1,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Delete Task",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}