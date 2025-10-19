/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'QScan';
  static const String appVersion = '1.0.0';
  static const String poweredBy = 'Jashvant';

  // Storage Keys
  static const String scanHistoryKey = 'scan_history';
  static const String themeKey = 'theme_mode';
  static const String firstLaunchKey = 'first_launch';

  // Scan Types
  static const String qrCode = 'QR Code';
  static const String barcode = 'Barcode';

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';

  // Animation Durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);

  // Limits
  static const int maxHistoryItems = 100;
  static const int codeDisplayLength = 50;

  // Messages
  static const String scanSuccessMessage = 'Code scanned successfully!';
  static const String scanErrorMessage = 'Failed to scan code';
  static const String permissionDeniedMessage = 'Camera permission is required';
  static const String emptyHistoryMessage = 'No scan history yet';
  static const String deleteConfirmMessage = 'Delete this scan?';

  // Validation
  static bool isValidUrl(String value) {
    final urlPattern = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlPattern.hasMatch(value);
  }

  static bool isValidEmail(String value) {
    final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailPattern.hasMatch(value);
  }
}
