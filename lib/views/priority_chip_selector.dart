import 'package:flutter/material.dart';

import '../colors.dart';

class PriorityChipSelector extends StatelessWidget {
  final String? selectedPriority;
  final ValueChanged<String> onPrioritySelected;

  const PriorityChipSelector({
    super.key,
    required this.selectedPriority,
    required this.onPrioritySelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> priorities = ["Basic", "Urgent", "Important"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: priorities.map((priority) {
        final bool isSelected = selectedPriority == priority;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ChoiceChip(
            label: Text(
              priority,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primaryBlue1,
                fontWeight: FontWeight.bold,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                onPrioritySelected(priority);
              }
            },
            selectedColor: AppColors.primaryBlue1,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppColors.primaryBlue1),
            ),
            showCheckmark: false,
          ),
        );
      }).toList(),
    );
  }
}
