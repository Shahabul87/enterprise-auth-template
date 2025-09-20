import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// Responsive builder widget that builds different layouts based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, BoxConstraints, DeviceType) builder;
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    Key? key,
    required this.builder,
    this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  factory ResponsiveBuilder.simple({
    Key? key,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    return ResponsiveBuilder(
      key: key,
      builder: (context, constraints, deviceType) {
        switch (deviceType) {
          case DeviceType.mobile:
            return mobile;
          case DeviceType.tablet:
            return tablet ?? mobile;
          case DeviceType.desktop:
            return desktop ?? tablet ?? mobile;
        }
      },
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = Responsive.getDeviceType(context);
        return builder(context, constraints, deviceType);
      },
    );
  }
}

/// Responsive widget that shows/hides based on screen size
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool hiddenOn;
  final bool visibleOn;
  final List<DeviceType> hiddenWhen;
  final List<DeviceType> visibleWhen;
  final Widget? replacement;

  const ResponsiveVisibility({
    Key? key,
    required this.child,
    this.hiddenOn = false,
    this.visibleOn = true,
    this.hiddenWhen = const [],
    this.visibleWhen = const [],
    this.replacement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.getDeviceType(context);

    bool isVisible = visibleOn && !hiddenOn;

    if (hiddenWhen.contains(deviceType)) {
      isVisible = false;
    }

    if (visibleWhen.isNotEmpty && !visibleWhen.contains(deviceType)) {
      isVisible = false;
    }

    if (!isVisible) {
      return replacement ?? const SizedBox.shrink();
    }

    return child;
  }
}

/// Responsive container with adaptive padding and margins
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.decoration,
    this.width,
    this.height,
    this.alignment,
    this.constraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    return Container(
      padding: padding ?? responsive.padding,
      margin: margin ?? responsive.margin,
      decoration: decoration,
      width: width,
      height: height,
      alignment: alignment,
      constraints: constraints,
      child: child,
    );
  }
}

/// Responsive grid view
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final int? mobileCrossAxisCount;
  final int? tabletCrossAxisCount;
  final int? desktopCrossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ResponsiveGridView({
    Key? key,
    required this.children,
    this.mobileCrossAxisCount,
    this.tabletCrossAxisCount,
    this.desktopCrossAxisCount,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
    this.childAspectRatio = 1.0,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    int crossAxisCount;
    if (responsive.isMobile) {
      crossAxisCount = mobileCrossAxisCount ?? 2;
    } else if (responsive.isTablet) {
      crossAxisCount = tabletCrossAxisCount ?? 3;
    } else {
      crossAxisCount = desktopCrossAxisCount ?? 4;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      childAspectRatio: childAspectRatio,
      padding: padding ?? responsive.padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      children: children,
    );
  }
}

/// Responsive row that converts to column on mobile
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool convertToColumnOnMobile;
  final double spacing;

  const ResponsiveRow({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.convertToColumnOnMobile = true,
    this.spacing = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    if (convertToColumnOnMobile && responsive.isMobile) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: _addSpacing(children, isColumn: true),
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: _addSpacing(children, isColumn: false),
    );
  }

  List<Widget> _addSpacing(List<Widget> widgets, {required bool isColumn}) {
    if (widgets.isEmpty) return widgets;

    final spacedWidgets = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      spacedWidgets.add(widgets[i]);
      if (i < widgets.length - 1) {
        spacedWidgets.add(
          isColumn ? SizedBox(height: spacing) : SizedBox(width: spacing),
        );
      }
    }
    return spacedWidgets;
  }
}

/// Responsive text that scales based on screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final bool scaleWithDevice;

  const ResponsiveText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
    this.scaleWithDevice = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    double? fontSize;
    if (scaleWithDevice) {
      if (responsive.isMobile) {
        fontSize = mobileFontSize ?? style?.fontSize;
      } else if (responsive.isTablet) {
        fontSize = tabletFontSize ?? style?.fontSize;
      } else {
        fontSize = desktopFontSize ?? style?.fontSize;
      }
    }

    final scaledStyle =
        style?.copyWith(
          fontSize: fontSize != null ? responsive.fontSize(fontSize) : null,
        ) ??
        TextStyle(fontSize: fontSize);

    return Text(
      text,
      style: scaledStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

/// Responsive sized box with adaptive dimensions
class ResponsiveSizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double? mobileWidth;
  final double? mobileHeight;
  final double? tabletWidth;
  final double? tabletHeight;
  final double? desktopWidth;
  final double? desktopHeight;
  final Widget? child;

  const ResponsiveSizedBox({
    Key? key,
    this.width,
    this.height,
    this.mobileWidth,
    this.mobileHeight,
    this.tabletWidth,
    this.tabletHeight,
    this.desktopWidth,
    this.desktopHeight,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    double? finalWidth;
    double? finalHeight;

    if (responsive.isMobile) {
      finalWidth = mobileWidth ?? width;
      finalHeight = mobileHeight ?? height;
    } else if (responsive.isTablet) {
      finalWidth = tabletWidth ?? width;
      finalHeight = tabletHeight ?? height;
    } else {
      finalWidth = desktopWidth ?? width;
      finalHeight = desktopHeight ?? height;
    }

    return SizedBox(
      width: finalWidth != null ? responsive.width(finalWidth) : null,
      height: finalHeight != null ? responsive.height(finalHeight) : null,
      child: child,
    );
  }
}
