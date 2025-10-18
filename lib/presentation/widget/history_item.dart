import 'package:flutter/material.dart';

// Example History data model
class HistoryItem {
  final String title;
  final String subtitle;
  final DateTime date;

  HistoryItem({
    required this.title,
    required this.subtitle,
    required this.date,
  });
}

// Reusable Custom Card widget
class HistoryCard extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback? onTap;

  const HistoryCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(item.date),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }
}
