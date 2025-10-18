import 'package:flutter/material.dart';
import 'package:qscan_app_flutter/presentation/widget/history_item.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  final List<HistoryItem> historyItems = [
    HistoryItem(
      title: "Scanned QR Code 1",
      subtitle: "Result: https://example.com",

      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    HistoryItem(
      title: "Scanned QR Code 2",
      subtitle: "Result: Flutter Package",
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    HistoryItem(
      title: "Scanned Barcode",
      subtitle: "Result: 1234567890123",
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: historyItems.isEmpty
          ? const Center(
              child: Text(
                "No history available",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: historyItems.length,
              itemBuilder: (context, index) {
                return HistoryCard(
                  item: historyItems[index],
                  onTap: () {
                    // You can handle tap to show detail
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Clicked: ${historyItems[index].title}"),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
