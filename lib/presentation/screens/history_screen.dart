import 'package:flutter/material.dart';
import 'package:qscan_app_flutter/presentation/model/history_item.dart';
import '../../core/utils/responsive_utils.dart';
import 'package:qscan_app_flutter/presentation/repository/history_repo.dart';
import 'package:qscan_app_flutter/presentation/widget/history_card.dart';
import 'package:qscan_app_flutter/presentation/screens/details/barcode_details_screen.dart';
import 'package:qscan_app_flutter/presentation/screens/details/link_details.dart';
import 'package:qscan_app_flutter/presentation/screens/details/payment_details.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryRepository _historyRepo = HistoryRepository();
  List<HistoryItem> _historyItems = <HistoryItem>[];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final items = _historyRepo.getAllHistory();
      setState(() {
        _historyItems = items;
      });
      debugPrint('Loaded history items: ${items.length}');
    } catch (e) {
      debugPrint('Error loading history: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToDetails(HistoryItem item) {
    final data = item.data.toLowerCase();
    Widget destination;

    // Determine which detail screen to show based on data type
    if (data.startsWith('http://') || data.startsWith('https://')) {
      // URL/Link
      destination = LinkDetailsScreen(url: item.data);
    } else if (data.startsWith('upi://') || data.contains('upi')) {
      // UPI Payment
      destination = PaymentDetailsScreen(payee: item.data);
    } else {
      // Default to Barcode/QR details
      destination = BarcodeDetailsScreen(code: item.data);
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtil(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _historyItems.isEmpty
          ? Center(
              child: Text(
                "No history available",
                style: TextStyle(
                  fontSize: responsive.sp(4),
                  color: Colors.grey,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.wp(4),
                  vertical: responsive.hp(2),
                ),
                itemCount: _historyItems.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: responsive.hp(1.5)),
                itemBuilder: (context, index) {
                  final item = _historyItems[index];
                  return Dismissible(
                    key: Key(item.date.toIso8601String() + item.data),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: responsive.wp(5)),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) async {
                      await _historyRepo.deleteHistoryItem(item);

                      setState(() {
                        _historyItems.removeAt(index);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Deleted "${item.data}"')),
                      );
                    },
                    child: HistoryCard(
                      item: item,
                      onTap: () => _navigateToDetails(item),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
