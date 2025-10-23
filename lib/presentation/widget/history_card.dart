import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/history_item.dart';

class HistoryCard extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback? onTap;

  const HistoryCard({super.key, required this.item, this.onTap});
  IconData _getIconForType(String type) {
    print('Type to icon mapping: $type');
    final lowerType = type.toLowerCase();

    if (lowerType.startsWith('http://') || lowerType.startsWith('https://')) {
      print('Icon: link');
      return Icons.link;
    }

    if (lowerType == 'barcode' ||
        lowerType == 'bar code' ||
        lowerType == 'code128' ||
        lowerType == 'ean13') {
      print('Icon: barcode');
      return Icons.qr_code_scanner;
    }

    if (lowerType.startsWith('upi://')) {
      print('Icon: payment');
      return Icons.payment;
    }

    if (lowerType == 'qr' || lowerType == 'qrcode' || lowerType == 'qr code') {
      print('Icon: qr code');
      return Icons.qr_code_2;
    }

    print('Icon: default history');
    return Icons.qr_code_scanner;
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'qr':
      case 'qr code':
        return Colors.indigo;
      case 'barcode':
        return Colors.teal;
      case 'upi':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d, yyyy • hh:mm a').format(item.date);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: _getColorForType(
                item.scanType,
              ).withOpacity(0.15),
              child: Icon(
                _getIconForType(item.scanType),
                color: _getColorForType(item.scanType),
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTitleForType(item.scanType, item.data),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.data.isNotEmpty
                        ? item.data.split('\n').first.trim()
                        : '(No data)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitleForType(String scanType, String data) {
    final lowerData = data.toLowerCase();

    if (lowerData.contains('upi://')) {
      return 'UPI Link';
    } else if (lowerData.contains('https:')) {
      return 'Link';
    } else if (lowerData.contains('http://') ||
        scanType.toLowerCase() == 'http://' ||
        scanType.toLowerCase() == 'http') {
      return 'QR Code';
    } else {
      // For any other data or number show Barcode
      return 'Barcode';
    }
  }
}
