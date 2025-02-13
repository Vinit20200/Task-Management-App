import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:task_management_app/colors.dart';
import 'package:task_management_app/views/priority_chip_selector.dart';

import '../models/task_model.dart';
import '../viewmodel/task_provider.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final DateTime date;

  const AddTaskScreen({super.key, required this.date});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  String _selectedPriority = "Basic"; // Default Priority

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date;
  }

  void _saveTask() {
    if (_titleController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final newTask = Task(
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _selectedDate!,
      priority: _selectedPriority, // Store priority in the Task model
    );

    ref.read(taskProvider.notifier).addTask(newTask);
    Navigator.pop(context);
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? Color(0xFF1E1E1E)  // Dark background
          : const Color(0xFFF6F6F6),  // Original light background
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Create Task',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
              Icons.arrow_back,
              color: isDarkMode ? Colors.white : Colors.black
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Task',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const Gap(8),
              TextField(
                controller: _titleController,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter task title',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  filled: true,
                  fillColor: isDarkMode
                      ? Color(0xFF2D2D2D)  // Dark input background
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey[800]! : Colors.transparent,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.primaryBlue1,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const Gap(20),
              Text(
                "What's the plan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const Gap(8),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Describe your plan',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  filled: true,
                  fillColor: isDarkMode
                      ? Color(0xFF2D2D2D)  // Dark input background
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey[800]! : Colors.transparent,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.primaryBlue1,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const Gap(20),

              // Priority Selection UI remains unchanged as it has its own styling
              PriorityChipSelector(
                selectedPriority: _selectedPriority,
                onPrioritySelected: (priority) {
                  setState(() {
                    _selectedPriority = priority;
                  });
                },
              ),

              const Gap(20),
              Text(
                'Due Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const Gap(8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Color(0xFF2D2D2D)  // Dark input background
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: isDarkMode
                        ? Border.all(color: Colors.grey[800]!)
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'Choose Date'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text(
                    'Create Task',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
