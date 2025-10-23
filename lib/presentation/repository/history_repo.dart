import 'package:hive/hive.dart';
import 'package:qscan_app_flutter/presentation/model/history_item.dart';

class HistoryRepository {
  static const _boxName = 'historyBox';

  Box<HistoryItem> get _box => Hive.box<HistoryItem>(_boxName);

  List<HistoryItem> getAllHistory() {
    final all = _box.values.toList();
    all.sort((a, b) => b.date.compareTo(a.date));
    return all;
  }

  int getTotalScans() {
    return _box.length;
  }

  int getScansToday() {
    final today = DateTime.now();
    return _box.values.where((item) {
      final date = item.date;
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).length;
  }

  Future<void> addHistoryItem(HistoryItem item) async {
    await _box.add(item);
  }

  Future<void> clearHistory() async {
    await _box.clear();
  }

  Future<void> deleteHistoryItem(HistoryItem item) async {
    final box = Hive.box('historybox');
    await box.delete(item);
  }
}
