import 'package:flutter/widgets.dart';

/// Utility class for responsive design
/// Usage: final responsive = ResponsiveUtil(context);
class ResponsiveUtil {
  final BuildContext context;
  late MediaQueryData _mediaQueryData;
  late double screenWidth;
  late double screenHeight;
  late double blockSizeHorizontal;
  late double blockSizeVertical;

  late double _safeAreaHorizontal;
  late double _safeAreaVertical;
  late double safeBlockHorizontal;
  late double safeBlockVertical;

  ResponsiveUtil(this.context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }

  /// Returns width percentage of screen
  /// Example: wp(50) returns 50% of screen width
  double wp(double percentage) {
    return blockSizeHorizontal * percentage;
  }

  /// Returns height percentage of screen
  /// Example: hp(20) returns 20% of screen height
  double hp(double percentage) {
    return blockSizeVertical * percentage;
  }

  /// Returns safe area width percentage
  double swp(double percentage) {
    return safeBlockHorizontal * percentage;
  }

  /// Returns safe area height percentage
  double shp(double percentage) {
    return safeBlockVertical * percentage;
  }

  /// Responsive font size based on screen width
  double sp(double size) {
    return blockSizeHorizontal * size * 0.5;
  }

  /// Check if device is in landscape mode
  bool get isLandscape => _mediaQueryData.orientation == Orientation.landscape;

  /// Check if device is tablet (width > 600)
  bool get isTablet => screenWidth >= 600;

  /// Check if device is mobile
  bool get isMobile => screenWidth < 600;

  /// Check if device is desktop
  bool get isDesktop => screenWidth >= 1200;

  /// Get appropriate padding based on device type
  double get defaultPadding {
    if (isDesktop) return 24.0;
    if (isTablet) return 20.0;
    return 16.0;
  }

  /// Get appropriate margin based on device type
  double get defaultMargin {
    if (isDesktop) return 20.0;
    if (isTablet) return 16.0;
    return 12.0;
  }

  /// Get appropriate border radius
  double get defaultRadius {
    if (isDesktop) return 16.0;
    if (isTablet) return 14.0;
    return 12.0;
  }
}
