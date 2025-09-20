import 'package:flutter/material.dart';

/// Empty state widget for when there's no content to display
class EmptyState extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? icon;
  final IconData? iconData;
  final double? iconSize;
  final Color? iconColor;
  final Widget? action;
  final VoidCallback? onAction;
  final String? actionLabel;
  final EdgeInsetsGeometry padding;

  const EmptyState({
    Key? key,
    this.title,
    this.message,
    this.icon,
    this.iconData,
    this.iconSize,
    this.iconColor,
    this.action,
    this.onAction,
    this.actionLabel,
    this.padding = const EdgeInsets.all(32),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      padding: padding,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null || iconData != null) ...[
            icon ??
                Icon(
                  iconData ?? Icons.inbox_outlined,
                  size: iconSize ?? 64,
                  color:
                      iconColor ?? colorScheme.onSurface.withValues(alpha: 0.4),
                ),
            const SizedBox(height: 16),
          ],
          if (title != null) ...[
            Text(
              title!,
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          if (message != null) ...[
            Text(
              message!,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
          if (action != null)
            action!
          else if (onAction != null && actionLabel != null)
            ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

/// Pre-configured empty states for common scenarios
class EmptyStates {
  EmptyStates._();

  /// No data empty state
  static Widget noData({String? message, VoidCallback? onRefresh}) {
    return EmptyState(
      iconData: Icons.folder_open_outlined,
      title: 'No Data',
      message: message ?? 'There is no data to display',
      onAction: onRefresh,
      actionLabel: onRefresh != null ? 'Refresh' : null,
    );
  }

  /// No search results empty state
  static Widget noSearchResults({
    String? searchTerm,
    VoidCallback? onClearSearch,
  }) {
    return EmptyState(
      iconData: Icons.search_off_outlined,
      title: 'No Results Found',
      message: searchTerm != null
          ? 'No results found for "$searchTerm"'
          : 'Try adjusting your search criteria',
      onAction: onClearSearch,
      actionLabel: onClearSearch != null ? 'Clear Search' : null,
    );
  }

  /// No network connection empty state
  static Widget noConnection({VoidCallback? onRetry}) {
    return EmptyState(
      iconData: Icons.wifi_off_outlined,
      title: 'No Connection',
      message: 'Please check your internet connection and try again',
      onAction: onRetry,
      actionLabel: 'Retry',
    );
  }

  /// Error empty state
  static Widget error({String? message, VoidCallback? onRetry}) {
    return EmptyState(
      iconData: Icons.error_outline,
      iconColor: Colors.red.shade400,
      title: 'Something Went Wrong',
      message: message ?? 'An error occurred while loading the content',
      onAction: onRetry,
      actionLabel: 'Try Again',
    );
  }

  /// No items empty state
  static Widget noItems({String? itemType, VoidCallback? onAdd}) {
    return EmptyState(
      iconData: Icons.inventory_2_outlined,
      title: itemType != null ? 'No $itemType' : 'No Items',
      message: itemType != null
          ? 'You haven\'t added any $itemType yet'
          : 'Start by adding your first item',
      onAction: onAdd,
      actionLabel: onAdd != null ? 'Add ${itemType ?? 'Item'}' : null,
    );
  }

  /// No notifications empty state
  static Widget noNotifications() {
    return const EmptyState(
      iconData: Icons.notifications_none_outlined,
      title: 'No Notifications',
      message: 'You\'re all caught up!',
    );
  }

  /// No messages empty state
  static Widget noMessages({VoidCallback? onStartConversation}) {
    return EmptyState(
      iconData: Icons.chat_bubble_outline,
      title: 'No Messages',
      message: 'Start a conversation to see messages here',
      onAction: onStartConversation,
      actionLabel: onStartConversation != null ? 'Start Conversation' : null,
    );
  }

  /// No favorites empty state
  static Widget noFavorites({VoidCallback? onExplore}) {
    return EmptyState(
      iconData: Icons.favorite_border,
      title: 'No Favorites',
      message: 'Items you favorite will appear here',
      onAction: onExplore,
      actionLabel: onExplore != null ? 'Explore' : null,
    );
  }

  /// Coming soon empty state
  static Widget comingSoon({String? feature}) {
    return EmptyState(
      iconData: Icons.rocket_launch_outlined,
      title: 'Coming Soon',
      message: feature != null
          ? '$feature will be available soon!'
          : 'This feature is under development',
    );
  }

  /// Access denied empty state
  static Widget accessDenied({VoidCallback? onRequestAccess}) {
    return EmptyState(
      iconData: Icons.lock_outline,
      iconColor: Colors.orange.shade600,
      title: 'Access Denied',
      message: 'You don\'t have permission to view this content',
      onAction: onRequestAccess,
      actionLabel: onRequestAccess != null ? 'Request Access' : null,
    );
  }
}

/// Custom illustrated empty state
class IllustratedEmptyState extends StatelessWidget {
  final Widget illustration;
  final String? title;
  final String? message;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  const IllustratedEmptyState({
    Key? key,
    required this.illustration,
    this.title,
    this.message,
    this.action,
    this.padding = const EdgeInsets.all(32),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      padding: padding,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 200, child: illustration),
          const SizedBox(height: 24),
          if (title != null) ...[
            Text(
              title!,
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          if (message != null) ...[
            Text(
              message!,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Animated empty state with subtle animations
class AnimatedEmptyState extends StatefulWidget {
  final IconData iconData;
  final String? title;
  final String? message;
  final Widget? action;

  const AnimatedEmptyState({
    Key? key,
    required this.iconData,
    this.title,
    this.message,
    this.action,
  }) : super(key: key);

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              widget.iconData,
              size: 80,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                if (widget.title != null) ...[
                  Text(
                    widget.title!,
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],
                if (widget.message != null) ...[
                  Text(
                    widget.message!,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
                if (widget.action != null) widget.action!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
