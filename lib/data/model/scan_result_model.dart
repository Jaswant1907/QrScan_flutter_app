import 'dart:convert';
import '../../domain/entities/scan_result.dart';

/// Data model extending domain entity with serialization capabilities
/// Handles conversion between JSON and domain entity
class ScanResultModel extends ScanResult {
  ScanResultModel({
    required super.id,
    required super.value,
    required super.type,
    required super.scannedAt,
    super.isFavorite,
  });

  /// Create model from domain entity
  factory ScanResultModel.fromEntity(ScanResult entity) {
    return ScanResultModel(
      id: entity.id,
      value: entity.value,
      type: entity.type,
      scannedAt: entity.scannedAt,
      isFavorite: entity.isFavorite,
    );
  }

  /// Convert model to domain entity
  ScanResult toEntity() {
    return ScanResult(
      id: id,
      value: value,
      type: type,
      scannedAt: scannedAt,
      isFavorite: isFavorite,
    );
  }

  /// Create model from JSON map
  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      id: json['id'] as String,
      value: json['value'] as String,
      type: json['type'] as String,
      scannedAt: DateTime.parse(json['scannedAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  /// Convert model to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'type': type,
      'scannedAt': scannedAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  /// Create model from JSON string
  factory ScanResultModel.fromJsonString(String jsonString) {
    return ScanResultModel.fromJson(json.decode(jsonString));
  }

  /// Convert model to JSON string
  String toJsonString() {
    return json.encode(toJson());
  }

  /// Create a copy with modified fields
  @override
  ScanResultModel copyWith({
    String? id,
    String? value,
    String? type,
    DateTime? scannedAt,
    bool? isFavorite,
  }) {
    return ScanResultModel(
      id: id ?? this.id,
      value: value ?? this.value,
      type: type ?? this.type,
      scannedAt: scannedAt ?? this.scannedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
