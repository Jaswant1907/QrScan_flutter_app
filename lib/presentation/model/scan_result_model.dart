import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import '../../domain/entities/scan_result_entity.dart';
part 'scan_result_model.g.dart';

@HiveType(typeId: 0)
class ScanResultModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String value;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final DateTime scannedAt;

  @HiveField(4)
  final bool isFavorite;

  @HiveField(5)
  final String? imagePath; // Store image path instead of File for Hive compatibility

  ScanResultModel({
    required this.id,
    required this.value,
    required this.type,
    required this.scannedAt,
    this.isFavorite = false,
    this.imagePath,
  });

  /// Constructor for quick scan creation with type analysis
  factory ScanResultModel.fromScan(String code, {File? imageFile}) {
    final now = DateTime.now();

    // --- Type Analysis Logic ---
    String determinedType;
    final Uri? uri = Uri.tryParse(code);

    if (uri != null && (uri.isScheme('http') || uri.isScheme('https'))) {
      determinedType = 'link';
    } else if (code.startsWith('tel:') ||
        RegExp(r'^\+?[0-9\s-]{7,}$').hasMatch(code)) {
      determinedType = 'phone';
    } else if (code.contains('@') && code.contains('.')) {
      determinedType = 'email';
    } else {
      determinedType = 'text';
    }

    return ScanResultModel(
      id: now.millisecondsSinceEpoch.toString(),
      value: code,
      type: determinedType,
      scannedAt: now,
      isFavorite: false,
      imagePath: imageFile?.path,
    );
  }

  /// Convert model to domain entity
  ScanResult toEntity() => ScanResult(
    id: id,
    value: value,
    type: type,
    scannedAt: scannedAt,
    isFavorite: isFavorite,
  );

  /// Create model from domain entity
  factory ScanResultModel.fromEntity(ScanResult entity) => ScanResultModel(
    id: entity.id,
    value: entity.value,
    type: entity.type,
    scannedAt: entity.scannedAt,
    isFavorite: entity.isFavorite,
  );

  /// JSON serialization
  factory ScanResultModel.fromJson(Map<String, dynamic> json) =>
      ScanResultModel(
        id: json['id'] as String,
        value: json['value'] as String,
        type: json['type'] as String,
        scannedAt: DateTime.parse(json['scannedAt'] as String),
        isFavorite: json['isFavorite'] as bool? ?? false,
        imagePath: json['imagePath'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'value': value,
    'type': type,
    'scannedAt': scannedAt.toIso8601String(),
    'isFavorite': isFavorite,
    'imagePath': imagePath,
  };

  factory ScanResultModel.fromJsonString(String jsonString) =>
      ScanResultModel.fromJson(json.decode(jsonString));

  String toJsonString() => json.encode(toJson());

  /// CopyWith method
  ScanResultModel copyWith({
    String? id,
    String? value,
    String? type,
    DateTime? scannedAt,
    bool? isFavorite,
    String? imagePath,
  }) => ScanResultModel(
    id: id ?? this.id,
    value: value ?? this.value,
    type: type ?? this.type,
    scannedAt: scannedAt ?? this.scannedAt,
    isFavorite: isFavorite ?? this.isFavorite,
    imagePath: imagePath ?? this.imagePath,
  );
}
