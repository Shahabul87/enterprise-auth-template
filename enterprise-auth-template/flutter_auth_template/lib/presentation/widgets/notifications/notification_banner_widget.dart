import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:flutter_auth_template/data/models/notification_models.dart';
import 'package:flutter_auth_template/data/services/notification_api_service.dart';

final notificationBannerProvider = StateNotifierProvider<NotificationBannerNotifier, NotificationBannerState>((ref) {
  return NotificationBannerNotifier(NotificationApiService());
});

class NotificationBannerState {
  final List<NotificationMessage> bannerNotifications;
  final bool isVisible;
  final bool isLoading;

  NotificationBannerState({
    required this.bannerNotifications,
    required this.isVisible,
    required this.isLoading,
  });

  NotificationBannerState copyWith({
    List<NotificationMessage>? bannerNotifications,
    bool? isVisible,
    bool? isLoading,
  }) {
    return NotificationBannerState(
      bannerNotifications: bannerNotifications ?? this.bannerNotifications,
      isVisible: isVisible ?? this.isVisible,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationBannerNotifier extends StateNotifier<NotificationBannerState> {
  final NotificationApiService _apiService;
  Timer? _refreshTimer;

  NotificationBannerNotifier(this._apiService)
      : super(NotificationBannerState(
          bannerNotifications: [],
          isVisible: false,
          isLoading: false,
        )) {
    _loadBannerNotifications();
    _setupPeriodicRefresh();
  }

  Future<void> _loadBannerNotifications() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Get high priority persistent notifications for banners
      final notifications = await _apiService.getNotifications(
        unreadOnly: true,
        limit: 5,
      );
      
      final bannerNotifications = notifications
          .where((n) => 
              n.isPersistent && 
              (n.priority == NotificationPriority.high || n.priority == NotificationPriority.urgent))
          .toList();

      state = state.copyWith(
        bannerNotifications: bannerNotifications,
        isVisible: bannerNotifications.isNotEmpty,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void _setupPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _loadBannerNotifications();
    });
  }

  void dismissNotification(String notificationId) async {
    try {
      await _apiService.markAsRead(notificationId);
      
      final updatedNotifications = state.bannerNotifications
          .where((n) => n.id != notificationId)
          .toList();
      
      state = state.copyWith(
        bannerNotifications: updatedNotifications,
        isVisible: updatedNotifications.isNotEmpty,
      );
    } catch (e) {
      // Handle error silently for banner dismissal
      print('Error dismissing banner notification: $e');
    }
  }

  void addNotification(NotificationMessage notification) {
    if (notification.isPersistent && 
        (notification.priority == NotificationPriority.high || 
         notification.priority == NotificationPriority.urgent)) {
      
      final updatedNotifications = [notification, ...state.bannerNotifications];
      
      state = state.copyWith(
        bannerNotifications: updatedNotifications,
        isVisible: true,
      );
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _apiService.dispose();
    super.dispose();
  }
}

class NotificationBannerWidget extends ConsumerWidget {
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final bool showActions;

  const NotificationBannerWidget({
    super.key,
    this.margin,
    this.borderRadius,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationBannerProvider);

    if (!state.isVisible || state.bannerNotifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: margin ?? const EdgeInsets.all(16),
      child: Column(
        children: state.bannerNotifications.map((notification) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NotificationBannerItem(
              notification: notification,
              borderRadius: borderRadius,
              showActions: showActions,
              onDismiss: () => ref
                  .read(notificationBannerProvider.notifier)
                  .dismissNotification(notification.id),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class NotificationBannerItem extends StatefulWidget {
  final NotificationMessage notification;
  final BorderRadius? borderRadius;
  final bool showActions;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  const NotificationBannerItem({
    super.key,
    required this.notification,
    this.borderRadius,
    this.showActions = true,
    this.onDismiss,
    this.onTap,
  });

  @override
  State<NotificationBannerItem> createState() => _NotificationBannerItemState();
}

class _NotificationBannerItemState extends State<NotificationBannerItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              border: Border.all(
                color: widget.notification.type.color.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.notification.type.color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.notification.type.color,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: widget.notification.type.color,
                        radius: 20,
                        child: Icon(
                          _getNotificationIcon(widget.notification.type),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.notification.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (widget.notification.priority == NotificationPriority.urgent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'URGENT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.notification.content,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTimestamp(widget.notification.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (widget.notification.expiresAt != null) ...[
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.timer_off,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Expires ${_formatTimestamp(widget.notification.expiresAt!)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (widget.showActions) ...[
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            if (widget.notification.actions?.isNotEmpty ?? false)
                              _buildActionButtons(),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: _dismiss,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (widget.notification.actions?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return Column(
      children: widget.notification.actions!.take(2).map((action) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: ElevatedButton(
            onPressed: () => _handleAction(action),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.notification.type.color,
              minimumSize: const Size(80, 32),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: Text(
              action.label,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleAction(NotificationAction action) {
    // Handle different action types
    switch (action.type) {
      case NotificationActionType.link:
        if (action.url != null) {
          // Navigate to URL or deep link
          // Implementation depends on your routing system
          Navigator.of(context).pushNamed(action.url!);
        }
        break;
      case NotificationActionType.button:
        // Handle custom button action with payload
        print('Button action: ${action.payload}');
        break;
      case NotificationActionType.dismiss:
        _dismiss();
        break;
      case NotificationActionType.snooze:
        // Implement snooze functionality
        _snooze();
        break;
    }

    // Track action analytics
    // Implementation would depend on your analytics service
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    });
  }

  void _snooze() {
    // Implement snooze logic - remove for a period then re-show
    _dismiss();
    // You would typically schedule the notification to reappear later
  }

  Color _getBackgroundColor() {
    switch (widget.notification.priority) {
      case NotificationPriority.urgent:
        return Colors.red.withOpacity(0.05);
      case NotificationPriority.high:
        return Colors.orange.withOpacity(0.05);
      case NotificationPriority.normal:
        return Colors.blue.withOpacity(0.05);
      case NotificationPriority.low:
        return Colors.grey.withOpacity(0.05);
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return Icons.info;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.security:
        return Icons.security;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.marketing:
        return Icons.campaign;
      case NotificationType.reminder:
        return Icons.schedule;
      case NotificationType.announcement:
        return Icons.announcement;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

class NotificationBannerManager extends ConsumerWidget {
  final Widget child;

  const NotificationBannerManager({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        child,
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 0,
          right: 0,
          child: const NotificationBannerWidget(),
        ),
      ],
    );
  }
}

class SystemAnnouncementBanner extends ConsumerWidget {
  final String title;
  final String message;
  final NotificationType type;
  final List<NotificationAction>? actions;
  final bool dismissible;
  final VoidCallback? onDismiss;

  const SystemAnnouncementBanner({
    super.key,
    required this.title,
    required this.message,
    this.type = NotificationType.announcement,
    this.actions,
    this.dismissible = true,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: type.color.withOpacity(0.1),
        border: Border.all(
          color: type.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _getTypeIcon(type),
              color: type.color,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: type.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (actions?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: actions!.map((action) {
                        return ElevatedButton(
                          onPressed: () => _handleAction(context, action),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: type.color,
                            minimumSize: const Size(0, 32),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                          ),
                          child: Text(
                            action.label,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            if (dismissible)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onDismiss,
                color: type.color,
              ),
          ],
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, NotificationAction action) {
    switch (action.type) {
      case NotificationActionType.link:
        if (action.url != null) {
          Navigator.of(context).pushNamed(action.url!);
        }
        break;
      case NotificationActionType.button:
        // Handle custom button action
        break;
      case NotificationActionType.dismiss:
        if (onDismiss != null) {
          onDismiss!();
        }
        break;
      case NotificationActionType.snooze:
        // Implement snooze logic
        break;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return Icons.info;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.security:
        return Icons.security;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.marketing:
        return Icons.campaign;
      case NotificationType.reminder:
        return Icons.schedule;
      case NotificationType.announcement:
        return Icons.announcement;
    }
  }
}