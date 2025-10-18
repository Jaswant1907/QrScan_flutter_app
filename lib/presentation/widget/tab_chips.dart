import 'package:flutter/material.dart';

class TabChips extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const TabChips({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.white70,
              offset: Offset(-2, -2),
              blurRadius: 4,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black12,
              offset: Offset(2, 2),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(labels.length, (index) {
            final bool isSelected = index == selectedIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(labels[index]),
                selected: isSelected,
                onSelected: (_) => onTap(index),
                selectedColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.transparent,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
