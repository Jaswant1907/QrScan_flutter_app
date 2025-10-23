import 'package:hive/hive.dart';

part 'history_item.g.dart';

@HiveType(typeId: 1)
class HistoryItem extends HiveObject {
  @HiveField(0)
  String scanType;

  @HiveField(1)
  String data;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String title;

  @HiveField(4)
  String subTitle;

  HistoryItem({
    required this.scanType,
    required this.data,
    required this.date,
    required this.title,
    required this.subTitle,
  });
}
