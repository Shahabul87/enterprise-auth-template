import 'package:flutter/material.dart';

/// Device type enum
enum DeviceType { mobile, tablet, desktop }

/// Screen size breakpoints
class Breakpoints {
  // Width breakpoints
  static const double mobileMaxWidth = 599;
  static const double tabletMinWidth = 600;
  static const double tabletMaxWidth = 1023;
  static const double desktopMinWidth = 1024;
  static const double largeDesktopMinWidth = 1440;
  static const double extraLargeDesktopMinWidth = 1920;

  // Height breakpoints
  static const double shortDeviceHeight = 600;
  static const double mediumDeviceHeight = 900;
  static const double tallDeviceHeight = 1200;

  // Common device sizes
  static const Size iphoneSE = Size(375, 667);
  static const Size iphone12 = Size(390, 844);
  static const Size iphone14Pro = Size(393, 852);
  static const Size iphone14ProMax = Size(430, 932);
  static const Size ipadMini = Size(744, 1133);
  static const Size ipadAir = Size(820, 1180);
  static const Size ipadPro11 = Size(834, 1194);
  static const Size ipadPro12 = Size(1024, 1366);
}

/// Responsive utility class
class Responsive extends InheritedWidget {
  final MediaQueryData mediaQuery;
  final Size screenSize;
  final DeviceType deviceType;
  final Orientation orientation;
  final TextScaler textScaler;

  const Responsive({
    Key? key,
    required this.mediaQuery,
    required this.screenSize,
    required this.deviceType,
    required this.orientation,
    required this.textScaler,
    required Widget child,
  }) : super(key: key, child: child);

  static Responsive of(BuildContext context) {
    final responsive = context.dependOnInheritedWidgetOfExactType<Responsive>();
    if (responsive != null) {
      return responsive;
    }

    // Fallback to creating from MediaQuery
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final deviceType = _getDeviceType(screenSize.width);

    return Responsive(
      mediaQuery: mediaQuery,
      screenSize: screenSize,
      deviceType: deviceType,
      orientation: mediaQuery.orientation,
      textScaler: mediaQuery.textScaler,
      child: const SizedBox.shrink(),
    );
  }

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return _getDeviceType(width);
  }

  static DeviceType _getDeviceType(double width) {
    if (width <= Breakpoints.mobileMaxWidth) {
      return DeviceType.mobile;
    } else if (width <= Breakpoints.tabletMaxWidth) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  @override
  bool updateShouldNotify(Responsive oldWidget) {
    return mediaQuery != oldWidget.mediaQuery ||
        screenSize != oldWidget.screenSize ||
        deviceType != oldWidget.deviceType ||
        orientation != oldWidget.orientation;
  }

  // Responsive getters
  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;
  bool get isLandscape => orientation == Orientation.landscape;
  bool get isPortrait => orientation == Orientation.portrait;

  // Screen dimensions
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  double get screenAspectRatio => screenSize.aspectRatio;

  // Safe area
  EdgeInsets get safeArea => mediaQuery.padding;
  double get safeAreaTop => mediaQuery.padding.top;
  double get safeAreaBottom => mediaQuery.padding.bottom;

  // Responsive sizing helpers
  double width(double value) => screenWidth * (value / 100);
  double height(double value) => screenHeight * (value / 100);

  // Responsive font sizing
  double fontSize(double size) {
    if (isMobile) {
      return size * 0.9;
    } else if (isTablet) {
      return size * 1.0;
    } else {
      return size * 1.1;
    }
  }

  // Responsive spacing
  double spacing(double baseSpacing) {
    if (isMobile) {
      return baseSpacing * 0.8;
    } else if (isTablet) {
      return baseSpacing * 1.0;
    } else {
      return baseSpacing * 1.2;
    }
  }

  // Responsive padding
  EdgeInsets get padding {
    if (isMobile) {
      return const EdgeInsets.all(16);
    } else if (isTablet) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  EdgeInsets get horizontalPadding {
    if (isMobile) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (isTablet) {
      return const EdgeInsets.symmetric(horizontal: 32);
    } else {
      return const EdgeInsets.symmetric(horizontal: 48);
    }
  }

  EdgeInsets get verticalPadding {
    if (isMobile) {
      return const EdgeInsets.symmetric(vertical: 16);
    } else if (isTablet) {
      return const EdgeInsets.symmetric(vertical: 24);
    } else {
      return const EdgeInsets.symmetric(vertical: 32);
    }
  }

  // Responsive margin
  EdgeInsets get margin {
    if (isMobile) {
      return const EdgeInsets.all(8);
    } else if (isTablet) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  // Grid columns
  int get gridColumns {
    if (isMobile) {
      return isLandscape ? 3 : 2;
    } else if (isTablet) {
      return isLandscape ? 4 : 3;
    } else {
      return 4;
    }
  }

  // Adaptive values
  T value<T>({required T mobile, T? tablet, T? desktop}) {
    if (isMobile) {
      return mobile;
    } else if (isTablet) {
      return tablet ?? mobile;
    } else {
      return desktop ?? tablet ?? mobile;
    }
  }
}

/// Responsive wrapper widget
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double? maxWidth;
  final double? minWidth;
  final bool centerContent;
  final EdgeInsetsGeometry? padding;

  const ResponsiveWrapper({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.maxWidth,
    this.minWidth,
    this.centerContent = true,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final deviceType = Responsive._getDeviceType(screenSize.width);

    Widget content = Responsive(
      mediaQuery: mediaQuery,
      screenSize: screenSize,
      deviceType: deviceType,
      orientation: mediaQuery.orientation,
      textScaler: mediaQuery.textScaler,
      child: child,
    );

    if (maxWidth != null || minWidth != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? double.infinity,
          minWidth: minWidth ?? 0,
        ),
        child: content,
      );
    }

    if (centerContent && deviceType == DeviceType.desktop) {
      content = Center(child: content);
    }

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (backgroundColor != null) {
      content = Container(color: backgroundColor, child: content);
    }

    return content;
  }
}

/// Screen type helper
class ScreenType {
  final BuildContext context;
  late final MediaQueryData _mediaQuery;
  late final Size _size;
  late final DeviceType _deviceType;

  ScreenType(this.context) {
    _mediaQuery = MediaQuery.of(context);
    _size = _mediaQuery.size;
    _deviceType = Responsive._getDeviceType(_size.width);
  }

  bool get isMobile => _deviceType == DeviceType.mobile;
  bool get isTablet => _deviceType == DeviceType.tablet;
  bool get isDesktop => _deviceType == DeviceType.desktop;

  bool get isSmallMobile => _size.width < 360;
  bool get isLargeMobile =>
      _size.width >= 360 && _size.width <= Breakpoints.mobileMaxWidth;
  bool get isSmallTablet =>
      _size.width >= Breakpoints.tabletMinWidth && _size.width < 768;
  bool get isLargeTablet =>
      _size.width >= 768 && _size.width <= Breakpoints.tabletMaxWidth;
  bool get isSmallDesktop =>
      _size.width >= Breakpoints.desktopMinWidth &&
      _size.width < Breakpoints.largeDesktopMinWidth;
  bool get isLargeDesktop => _size.width >= Breakpoints.largeDesktopMinWidth;

  bool get isShortDevice => _size.height < Breakpoints.shortDeviceHeight;
  bool get isTallDevice => _size.height > Breakpoints.tallDeviceHeight;
}
