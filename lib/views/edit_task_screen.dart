import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:task_management_app/colors.dart';
import 'package:task_management_app/views/home_screen.dart';
import 'package:task_management_app/views/priority_chip_selector.dart';

import '../models/task_model.dart';
import '../viewmodel/task_provider.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _selectedPriority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _selectedDate = widget.task.dueDate;
    _selectedPriority = widget.task.priority;
  }

  void _updateTask() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final updatedTask = widget.task.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _selectedDate,
      priority: _selectedPriority,
    );

    ref.read(taskProvider.notifier).updateTask(updatedTask);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeScreen()), (route) => false);
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF6F6F6),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Edit Task',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Enter task title',
                  hintStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  filled: true,
                  fillColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const Gap(20),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Describe your plan',
                  hintStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  filled: true,
                  fillColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const Gap(20),
              PriorityChipSelector(
                selectedPriority: _selectedPriority,
                onPrioritySelected: (priority) {
                  setState(() {
                    _selectedPriority = priority;
                  });
                },
              ),
              const Gap(20),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      Icon(Icons.calendar_today, color: isDarkMode ? Colors.grey[400] : Colors.grey),
                    ],
                  ),
                ),
              ),
              const Gap(40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text('Update Task', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
