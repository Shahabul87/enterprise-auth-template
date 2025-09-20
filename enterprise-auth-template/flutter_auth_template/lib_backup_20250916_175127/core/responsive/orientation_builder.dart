import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Orientation layout builder
class OrientationLayoutBuilder extends StatefulWidget {
  final Widget Function(BuildContext, Orientation) portrait;
  final Widget Function(BuildContext, Orientation)? landscape;
  final List<DeviceOrientation>? supportedOrientations;
  final bool lockOrientation;

  const OrientationLayoutBuilder({
    Key? key,
    required this.portrait,
    this.landscape,
    this.supportedOrientations,
    this.lockOrientation = false,
  }) : super(key: key);

  @override
  State<OrientationLayoutBuilder> createState() =>
      _OrientationLayoutBuilderState();
}

class _OrientationLayoutBuilderState extends State<OrientationLayoutBuilder> {
  @override
  void initState() {
    super.initState();
    if (widget.lockOrientation && widget.supportedOrientations != null) {
      SystemChrome.setPreferredOrientations(widget.supportedOrientations!);
    }
  }

  @override
  void dispose() {
    if (widget.lockOrientation) {
      // Reset to default orientations
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape && widget.landscape != null) {
          return widget.landscape!(context, orientation);
        }
        return widget.portrait(context, orientation);
      },
    );
  }
}

/// Adaptive orientation widget
class AdaptiveOrientation extends StatelessWidget {
  final Widget child;
  final bool forcePortraitOnMobile;
  final bool forceLandscapeOnTablet;
  final EdgeInsetsGeometry? portraitPadding;
  final EdgeInsetsGeometry? landscapePadding;
  final AlignmentGeometry? portraitAlignment;
  final AlignmentGeometry? landscapeAlignment;

  const AdaptiveOrientation({
    Key? key,
    required this.child,
    this.forcePortraitOnMobile = false,
    this.forceLandscapeOnTablet = false,
    this.portraitPadding,
    this.landscapePadding,
    this.portraitAlignment,
    this.landscapeAlignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;

        return Container(
          padding: isPortrait ? portraitPadding : landscapePadding,
          alignment: isPortrait ? portraitAlignment : landscapeAlignment,
          child: child,
        );
      },
    );
  }
}

/// Orientation-aware scaffold
class OrientationAwareScaffold extends StatelessWidget {
  final PreferredSizeWidget? portraitAppBar;
  final PreferredSizeWidget? landscapeAppBar;
  final Widget portraitBody;
  final Widget? landscapeBody;
  final Widget? portraitBottomNavigationBar;
  final Widget? landscapeNavigationRail;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;

  const OrientationAwareScaffold({
    Key? key,
    this.portraitAppBar,
    this.landscapeAppBar,
    required this.portraitBody,
    this.landscapeBody,
    this.portraitBottomNavigationBar,
    this.landscapeNavigationRail,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return _buildLandscapeLayout(context);
        }
        return _buildPortraitLayout(context);
      },
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return Scaffold(
      appBar: portraitAppBar,
      body: portraitBody,
      bottomNavigationBar: portraitBottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    if (landscapeNavigationRail != null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Row(
          children: [
            landscapeNavigationRail!,
            const VerticalDivider(width: 1),
            Expanded(
              child: Scaffold(
                appBar: landscapeAppBar ?? portraitAppBar,
                body: landscapeBody ?? portraitBody,
                floatingActionButton: floatingActionButton,
                floatingActionButtonLocation: floatingActionButtonLocation,
                endDrawer: endDrawer,
                backgroundColor: backgroundColor,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: landscapeAppBar ?? portraitAppBar,
      body: landscapeBody ?? portraitBody,
      bottomNavigationBar: portraitBottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
    );
  }
}

/// Safe area orientation wrapper
class SafeAreaOrientation extends StatelessWidget {
  final Widget child;
  final bool maintainBottomViewPadding;
  final EdgeInsets? minimumPortraitPadding;
  final EdgeInsets? minimumLandscapePadding;

  const SafeAreaOrientation({
    Key? key,
    required this.child,
    this.maintainBottomViewPadding = false,
    this.minimumPortraitPadding,
    this.minimumLandscapePadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;

        return SafeArea(
          maintainBottomViewPadding: maintainBottomViewPadding,
          minimum: isPortrait
              ? minimumPortraitPadding ?? EdgeInsets.zero
              : minimumLandscapePadding ?? EdgeInsets.zero,
          child: child,
        );
      },
    );
  }
}

/// Orientation lock widget
class OrientationLock extends StatefulWidget {
  final Widget child;
  final List<DeviceOrientation> allowedOrientations;
  final bool lockOnInit;

  const OrientationLock({
    Key? key,
    required this.child,
    required this.allowedOrientations,
    this.lockOnInit = true,
  }) : super(key: key);

  @override
  State<OrientationLock> createState() => _OrientationLockState();
}

class _OrientationLockState extends State<OrientationLock> {
  @override
  void initState() {
    super.initState();
    if (widget.lockOnInit) {
      _setOrientations();
    }
  }

  @override
  void dispose() {
    _resetOrientations();
    super.dispose();
  }

  void _setOrientations() {
    SystemChrome.setPreferredOrientations(widget.allowedOrientations);
  }

  void _resetOrientations() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Orientation utilities
class OrientationUtils {
  OrientationUtils._();

  /// Lock to portrait orientation
  static Future<void> lockPortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Lock to landscape orientation
  static Future<void> lockLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Lock to specific orientation
  static Future<void> lockOrientation(DeviceOrientation orientation) async {
    await SystemChrome.setPreferredOrientations([orientation]);
  }

  /// Unlock all orientations
  static Future<void> unlockAllOrientations() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Get current orientation
  static Orientation getCurrentOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Check if portrait
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Check if landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get orientation-specific value
  static T getOrientationValue<T>(
    BuildContext context, {
    required T portrait,
    required T landscape,
  }) {
    return isPortrait(context) ? portrait : landscape;
  }
}

/// Orientation transition widget
class OrientationTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const OrientationTransition({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      child: KeyedSubtree(
        key: ValueKey(MediaQuery.of(context).orientation),
        child: child,
      ),
    );
  }
}
