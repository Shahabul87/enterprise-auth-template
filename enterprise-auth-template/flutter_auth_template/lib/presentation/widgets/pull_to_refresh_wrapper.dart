import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

/// A wrapper widget that adds pull-to-refresh functionality
class PullToRefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final double displacement;
  final double edgeOffset;
  final bool enabled;

  const PullToRefreshWrapper({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.backgroundColor,
    this.indicatorColor,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final theme = Theme.of(context);
    final platform = Theme.of(context).platform;

    // Use platform-specific refresh indicator
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: onRefresh),
          SliverFillRemaining(child: child),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      color: indicatorColor ?? theme.colorScheme.primary,
      displacement: displacement,
      edgeOffset: edgeOffset,
      child: child,
    );
  }
}

/// Custom pull to refresh with more control
class CustomPullToRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Widget? refreshIndicator;
  final double triggerDistance;
  final Duration animationDuration;
  final bool enabled;
  final ScrollController? scrollController;

  const CustomPullToRefresh({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.refreshIndicator,
    this.triggerDistance = 100.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.enabled = true,
    this.scrollController,
  }) : super(key: key);

  @override
  State<CustomPullToRefresh> createState() => _CustomPullToRefreshState();
}

class _CustomPullToRefreshState extends State<CustomPullToRefresh>
    with TickerProviderStateMixin {
  late AnimationController _positionController;
  late AnimationController _scaleController;
  late ScrollController _scrollController;

  double _dragOffset = 0.0;
  bool _isRefreshing = false;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _positionController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: 0.0,
    );
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void dispose() {
    _positionController.dispose();
    _scaleController.dispose();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.enabled || _isRefreshing) return false;

    if (notification is ScrollStartNotification) {
      _isDragging = true;
      _dragOffset = 0.0;
    } else if (notification is OverscrollNotification) {
      if (notification.overscroll < 0.0) {
        _dragOffset -= notification.overscroll;
        _updateIndicator();
      }
    } else if (notification is ScrollEndNotification) {
      if (_isDragging) {
        _isDragging = false;
        _handleRefresh();
      }
    }

    return false;
  }

  void _updateIndicator() {
    final double progress = (_dragOffset / widget.triggerDistance).clamp(
      0.0,
      1.0,
    );
    _scaleController.value = progress;
    _positionController.value = progress;
  }

  Future<void> _handleRefresh() async {
    if (_dragOffset >= widget.triggerDistance && !_isRefreshing) {
      setState(() {
        _isRefreshing = true;
      });

      await widget.onRefresh();

      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
        _positionController.animateTo(0.0);
        _scaleController.animateTo(0.0);
      }
    } else {
      _positionController.animateTo(0.0);
      _scaleController.animateTo(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        children: [
          widget.child,
          AnimatedBuilder(
            animation: _positionController,
            builder: (context, child) {
              return Positioned(
                top: _positionController.value * 60,
                left: 0,
                right: 0,
                child: Center(
                  child: ScaleTransition(
                    scale: _scaleController,
                    child:
                        widget.refreshIndicator ??
                        _buildDefaultIndicator(context),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultIndicator(BuildContext context) {
    if (_isRefreshing) {
      return Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.arrow_downward,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// Smart refresh indicator that adapts to content type
class SmartRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Future<void> Function()? onLoadMore;
  final bool enablePullDown;
  final bool enablePullUp;
  final Widget? header;
  final Widget? footer;
  final VoidCallback? onRefreshComplete;
  final VoidCallback? onLoadComplete;

  const SmartRefreshIndicator({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.onLoadMore,
    this.enablePullDown = true,
    this.enablePullUp = false,
    this.header,
    this.footer,
    this.onRefreshComplete,
    this.onLoadComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      child: SmartRefresher(
        enablePullDown: enablePullDown,
        enablePullUp: enablePullUp && onLoadMore != null,
        onRefresh: onRefresh,
        onLoading: onLoadMore,
        header: header ?? const ClassicHeader(),
        footer: footer ?? const ClassicFooter(),
        child: child,
      ),
    );
  }
}

/// Configuration for smart refresh
class RefreshConfiguration extends InheritedWidget {
  final double headerTriggerDistance;
  final double footerTriggerDistance;
  final Duration animationDuration;
  final bool hideFooterWhenNotFull;

  const RefreshConfiguration({
    Key? key,
    required Widget child,
    this.headerTriggerDistance = 80.0,
    this.footerTriggerDistance = 80.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.hideFooterWhenNotFull = true,
  }) : super(key: key, child: child);

  static RefreshConfiguration? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RefreshConfiguration>();
  }

  @override
  bool updateShouldNotify(RefreshConfiguration oldWidget) {
    return headerTriggerDistance != oldWidget.headerTriggerDistance ||
        footerTriggerDistance != oldWidget.footerTriggerDistance ||
        animationDuration != oldWidget.animationDuration ||
        hideFooterWhenNotFull != oldWidget.hideFooterWhenNotFull;
  }
}

/// Smart refresher widget (simplified version)
class SmartRefresher extends StatefulWidget {
  final Widget child;
  final bool enablePullDown;
  final bool enablePullUp;
  final Future<void> Function() onRefresh;
  final Future<void> Function()? onLoading;
  final Widget? header;
  final Widget? footer;

  const SmartRefresher({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.onLoading,
    this.enablePullDown = true,
    this.enablePullUp = false,
    this.header,
    this.footer,
  }) : super(key: key);

  @override
  State<SmartRefresher> createState() => _SmartRefresherState();
}

class _SmartRefresherState extends State<SmartRefresher> {
  @override
  Widget build(BuildContext context) {
    Widget result = widget.child;

    if (widget.enablePullDown) {
      result = RefreshIndicator(onRefresh: widget.onRefresh, child: result);
    }

    return result;
  }
}

/// Classic header for smart refresh
class ClassicHeader extends StatelessWidget {
  const ClassicHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

/// Classic footer for smart refresh
class ClassicFooter extends StatelessWidget {
  const ClassicFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
