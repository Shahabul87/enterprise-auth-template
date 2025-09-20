import 'package:flutter/material.dart';
import 'breakpoints.dart';
import 'responsive_builder.dart';

/// Adaptive scaffold that changes layout based on screen size
class AdaptiveScaffold extends StatelessWidget {
  final Widget? appBar;
  final Widget body;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool useNavigationRail;
  final List<NavigationItem>? navigationItems;
  final int selectedIndex;
  final ValueChanged<int>? onNavigationChanged;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;

  const AdaptiveScaffold({
    Key? key,
    this.appBar,
    required this.body,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.useNavigationRail = true,
    this.navigationItems,
    this.selectedIndex = 0,
    this.onNavigationChanged,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints, deviceType) {
        // Desktop layout with navigation rail
        if (deviceType == DeviceType.desktop && useNavigationRail) {
          return _buildDesktopLayout(context);
        }

        // Tablet layout with optional navigation rail
        if (deviceType == DeviceType.tablet) {
          return _buildTabletLayout(context);
        }

        // Mobile layout with bottom navigation
        return _buildMobileLayout(context);
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: appBar != null ? appBar as PreferredSizeWidget : null,
      body: body,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar:
          bottomNavigationBar ??
          (navigationItems != null ? _buildBottomNavigation(context) : null),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape && useNavigationRail) {
      return _buildDesktopLayout(context);
    }

    return _buildMobileLayout(context);
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          if (navigationItems != null) _buildNavigationRail(context),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: Scaffold(
              appBar: appBar != null ? appBar as PreferredSizeWidget : null,
              body: body,
              endDrawer: endDrawer,
              floatingActionButton: floatingActionButton,
              floatingActionButtonLocation: floatingActionButtonLocation,
              backgroundColor: backgroundColor,
              extendBodyBehindAppBar: extendBodyBehindAppBar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onNavigationChanged,
      extended:
          MediaQuery.of(context).size.width > Breakpoints.largeDesktopMinWidth,
      labelType: NavigationRailLabelType.none,
      destinations: navigationItems!.map((item) {
        return NavigationRailDestination(
          icon: item.icon,
          selectedIcon: item.selectedIcon ?? item.icon,
          label: Text(item.label),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onNavigationChanged,
      destinations: navigationItems!.map((item) {
        return NavigationDestination(
          icon: item.icon,
          selectedIcon: item.selectedIcon ?? item.icon,
          label: item.label,
        );
      }).toList(),
    );
  }
}

/// Navigation item model
class NavigationItem {
  final Widget icon;
  final Widget? selectedIcon;
  final String label;
  final Widget? badge;

  const NavigationItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.badge,
  });
}

/// Master-detail layout for tablets and desktops
class MasterDetailLayout extends StatefulWidget {
  final Widget Function(BuildContext, int?, bool) masterBuilder;
  final Widget Function(BuildContext, int) detailBuilder;
  final int itemCount;
  final int? selectedIndex;
  final ValueChanged<int?>? onSelectionChanged;
  final double masterWidth;
  final double minMasterWidth;
  final double maxMasterWidth;
  final bool showDetailOnMobile;
  final Widget? emptyDetail;

  const MasterDetailLayout({
    Key? key,
    required this.masterBuilder,
    required this.detailBuilder,
    required this.itemCount,
    this.selectedIndex,
    this.onSelectionChanged,
    this.masterWidth = 320,
    this.minMasterWidth = 280,
    this.maxMasterWidth = 400,
    this.showDetailOnMobile = false,
    this.emptyDetail,
  }) : super(key: key);

  @override
  State<MasterDetailLayout> createState() => _MasterDetailLayoutState();
}

class _MasterDetailLayoutState extends State<MasterDetailLayout> {
  int? _selectedIndex;
  bool _showingDetail = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(MasterDetailLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _selectedIndex = widget.selectedIndex;
    }
  }

  void _onBackPressed() {
    setState(() {
      _showingDetail = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints, deviceType) {
        if (deviceType == DeviceType.mobile) {
          return _buildMobileLayout(context);
        }
        return _buildTabletDesktopLayout(context, deviceType);
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    if (_showingDetail && _selectedIndex != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _onBackPressed();
          }
        },
        child: widget.detailBuilder(context, _selectedIndex!),
      );
    }

    return widget.masterBuilder(context, _selectedIndex, false);
  }

  Widget _buildTabletDesktopLayout(
    BuildContext context,
    DeviceType deviceType,
  ) {
    final isTablet = deviceType == DeviceType.tablet;
    final masterWidth = isTablet ? widget.minMasterWidth : widget.masterWidth;

    return Row(
      children: [
        SizedBox(
          width: masterWidth.clamp(
            widget.minMasterWidth,
            widget.maxMasterWidth,
          ),
          child: widget.masterBuilder(context, _selectedIndex, true),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: _selectedIndex != null
              ? widget.detailBuilder(context, _selectedIndex!)
              : widget.emptyDetail ?? _buildEmptyDetail(context),
        ),
      ],
    );
  }

  Widget _buildEmptyDetail(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Select an item to view details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Adaptive dialog that adjusts size based on screen
class AdaptiveDialog extends StatelessWidget {
  final Widget? title;
  final Widget content;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? contentPadding;
  final bool scrollable;
  final double? maxWidth;
  final double? maxHeight;

  const AdaptiveDialog({
    Key? key,
    this.title,
    required this.content,
    this.actions,
    this.contentPadding,
    this.scrollable = false,
    this.maxWidth,
    this.maxHeight,
  }) : super(key: key);

  static Future<T?> show<T>({
    required BuildContext context,
    Widget? title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
    double? maxWidth,
    double? maxHeight,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AdaptiveDialog(
        title: title,
        content: content,
        actions: actions,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    double dialogMaxWidth;
    double dialogMaxHeight;

    if (responsive.isMobile) {
      dialogMaxWidth = responsive.screenWidth * 0.9;
      dialogMaxHeight = responsive.screenHeight * 0.8;
    } else if (responsive.isTablet) {
      dialogMaxWidth = responsive.screenWidth * 0.7;
      dialogMaxHeight = responsive.screenHeight * 0.7;
    } else {
      dialogMaxWidth = 600;
      dialogMaxHeight = responsive.screenHeight * 0.6;
    }

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? dialogMaxWidth,
          maxHeight: maxHeight ?? dialogMaxHeight,
        ),
        child: AlertDialog(
          title: title,
          content: scrollable ? SingleChildScrollView(child: content) : content,
          actions: actions,
          contentPadding: contentPadding,
          scrollable: scrollable,
        ),
      ),
    );
  }
}

/// Two-pane layout for tablets
class TwoPaneLayout extends StatelessWidget {
  final Widget startPane;
  final Widget endPane;
  final double startPaneWidth;
  final double minStartPaneWidth;
  final double maxStartPaneWidth;
  final bool resizable;
  final Axis direction;
  final Widget? divider;

  const TwoPaneLayout({
    Key? key,
    required this.startPane,
    required this.endPane,
    this.startPaneWidth = 0.4,
    this.minStartPaneWidth = 0.3,
    this.maxStartPaneWidth = 0.7,
    this.resizable = false,
    this.direction = Axis.horizontal,
    this.divider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    // On mobile, stack panes vertically
    if (responsive.isMobile && direction == Axis.horizontal) {
      return Column(
        children: [
          Expanded(child: startPane),
          if (divider != null) divider! else const Divider(height: 1),
          Expanded(child: endPane),
        ],
      );
    }

    if (direction == Axis.vertical) {
      return Column(
        children: [
          Expanded(flex: (startPaneWidth * 100).toInt(), child: startPane),
          if (divider != null) divider! else const Divider(height: 1),
          Expanded(flex: ((1 - startPaneWidth) * 100).toInt(), child: endPane),
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: (startPaneWidth * 100).toInt(), child: startPane),
        if (divider != null) divider! else const VerticalDivider(width: 1),
        Expanded(flex: ((1 - startPaneWidth) * 100).toInt(), child: endPane),
      ],
    );
  }
}
