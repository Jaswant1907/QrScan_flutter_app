class ScanResult {
  final String id;
  final String value;
  final String type;
  final DateTime scannedAt;
  final bool isFavorite;

  ScanResult({
    required this.id,
    required this.value,
    required this.type,
    required this.scannedAt,
    this.isFavorite = false,
  });

  /// Create a copy with modified fields
  ScanResult copyWith({
    String? id,
    String? value,
    String? type,
    DateTime? scannedAt,
    bool? isFavorite,
  }) {
    return ScanResult(
      id: id ?? this.id,
      value: value ?? this.value,
      type: type ?? this.type,
      scannedAt: scannedAt ?? this.scannedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Check if the scanned value is a URL
  bool get isUrl {
    final urlPattern = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlPattern.hasMatch(value);
  }

  /// Check if the scanned value is an email
  bool get isEmail {
    final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailPattern.hasMatch(value);
  }

  /// Check if the scanned value is a phone number
  bool get isPhone {
    final phonePattern = RegExp(r'^\+?[\d\s\-\(\)]+$');
    return phonePattern.hasMatch(value) && value.length >= 10;
  }

  /// Get display value (truncated if too long)
  String getDisplayValue({int maxLength = 50}) {
    if (value.length <= maxLength) return value;
    return '${value.substring(0, maxLength)}...';
  }

  @override
  String toString() {
    return 'ScanResult(id: $id, value: $value, type: $type, scannedAt: $scannedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScanResult &&
        other.id == id &&
        other.value == value &&
        other.type == type &&
        other.scannedAt == scannedAt &&
        other.isFavorite == isFavorite;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        value.hashCode ^
        type.hashCode ^
        scannedAt.hashCode ^
        isFavorite.hashCode;
  }
}
