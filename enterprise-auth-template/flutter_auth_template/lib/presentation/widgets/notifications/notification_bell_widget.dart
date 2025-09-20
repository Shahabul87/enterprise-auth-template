import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:flutter_auth_template/data/models/notification_models.dart';
import 'package:flutter_auth_template/data/services/notification_api_service.dart';
import 'package:flutter_auth_template/presentation/providers/websocket_provider.dart';

final notificationBellProvider = StateNotifierProvider<NotificationBellNotifier, NotificationBellState>((ref) {
  final apiService = NotificationApiService();
  final websocketProvider = ref.watch(websocketStateProvider.notifier);
  return NotificationBellNotifier(apiService, websocketProvider);
});

class NotificationBellState {
  final List<NotificationMessage> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  NotificationBellState({
    required this.notifications,
    required this.unreadCount,
    required this.isLoading,
    this.error,
  });

  NotificationBellState copyWith({
    List<NotificationMessage>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) {
    return NotificationBellState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class NotificationBellNotifier extends StateNotifier<NotificationBellState> {
  final NotificationApiService _apiService;
  final WebSocketProviderNotifier _websocketProvider;
  StreamSubscription<Map<String, dynamic>>? _websocketSubscription;
  Timer? _refreshTimer;

  NotificationBellNotifier(this._apiService, this._websocketProvider) 
      : super(NotificationBellState(
          notifications: [],
          unreadCount: 0,
          isLoading: false,
        )) {
    _initialize();
  }

  void _initialize() {
    _loadNotifications();
    _setupWebSocketListener();
    _setupPeriodicRefresh();
  }

  Future<void> _loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final results = await Future.wait([
        _apiService.getNotifications(limit: 50),
        _apiService.getUnreadCount(),
      ]);
      
      final notifications = results[0] as List<NotificationMessage>;
      final unreadCount = results[1] as int;
      
      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void _setupWebSocketListener() {
    _websocketSubscription = _websocketProvider.events.listen((event) {
      if (event['type'] == 'notification') {
        _handleNewNotification(event);
      }
    });
  }

  void _setupPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _loadNotifications();
    });
  }

  void _handleNewNotification(Map<String, dynamic> event) {
    try {
      final notification = NotificationMessage.fromJson(event['data']);
      final updatedNotifications = [notification, ...state.notifications];
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: state.unreadCount + 1,
      );
    } catch (e) {
      // Handle parsing error silently
      print('Error parsing notification: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.markAsRead(notificationId);
      
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == notificationId && !n.isRead) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }
        return n;
      }).toList();
      
      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiService.markAllAsRead();
      
      final updatedNotifications = state.notifications.map((n) {
        if (!n.isRead) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }
        return n;
      }).toList();
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiService.deleteNotification(notificationId);
      
      final updatedNotifications = state.notifications
          .where((n) => n.id != notificationId)
          .toList();
      
      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refresh() async {
    await _loadNotifications();
  }

  @override
  void dispose() {
    _websocketSubscription?.cancel();
    _refreshTimer?.cancel();
    _apiService.dispose();
    super.dispose();
  }
}

class NotificationBellWidget extends ConsumerWidget {
  final VoidCallback? onTap;
  final bool showBadge;
  final Color? badgeColor;

  const NotificationBellWidget({
    super.key,
    this.onTap,
    this.showBadge = true,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationBellProvider);
    
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: onTap ?? () => _showNotificationPanel(context, ref),
        ),
        if (showBadge && state.unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: badgeColor ?? Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                state.unreadCount > 99 ? '99+' : state.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _showNotificationPanel(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => NotificationPanelWidget(
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class NotificationPanelWidget extends ConsumerWidget {
  final ScrollController scrollController;

  const NotificationPanelWidget({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationBellProvider);
    final notifier = ref.watch(notificationBellProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Row(
                  children: [
                    if (state.unreadCount > 0)
                      TextButton(
                        onPressed: () => notifier.markAllAsRead(),
                        child: const Text('Mark all read'),
                      ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => notifier.refresh(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.notifications.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No notifications',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: state.notifications.length,
                        itemBuilder: (context, index) {
                          final notification = state.notifications[index];
                          return NotificationItemWidget(
                            notification: notification,
                            onTap: () => _handleNotificationTap(
                              context, ref, notification,
                            ),
                            onDismiss: () => notifier.deleteNotification(
                              notification.id,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    NotificationMessage notification,
  ) {
    final notifier = ref.read(notificationBellProvider.notifier);
    
    if (!notification.isRead) {
      notifier.markAsRead(notification.id);
    }

    // Handle deep links
    if (notification.deepLink != null) {
      // Navigate to specific page based on deep link
      // Implementation depends on your routing system
      Navigator.of(context).pushNamed(notification.deepLink!);
    }

    // Track analytics
    ref.read(notificationApiServiceProvider).trackNotificationAction(
      notificationId: notification.id,
      actionId: 'view',
    );
  }
}

class NotificationItemWidget extends StatelessWidget {
  final NotificationMessage notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDismiss(),
      child: Container(
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : Colors.blue.withOpacity(0.05),
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: notification.type.color,
            child: Icon(
              _getNotificationIcon(notification.type),
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Chip(
                    label: Text(
                      notification.priority.displayName,
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: notification.priority.color.withOpacity(0.2),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTimestamp(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: notification.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    notification.imageUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                  ),
                )
              : Icon(
                  notification.isRead
                      ? Icons.mark_email_read
                      : Icons.mark_email_unread,
                  color: notification.isRead ? Colors.grey : Colors.blue,
                ),
          onTap: onTap,
        ),
      ),
    );
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

class NotificationToastWidget extends StatefulWidget {
  final NotificationMessage notification;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationToastWidget({
    super.key,
    required this.notification,
    this.duration = const Duration(seconds: 4),
    this.onTap,
    this.onDismiss,
  });

  @override
  State<NotificationToastWidget> createState() => _NotificationToastWidgetState();
}

class _NotificationToastWidgetState extends State<NotificationToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_animationController);

    _animationController.forward();

    // Auto dismiss after duration
    Timer(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: widget.notification.type.color.withOpacity(0.3),
              width: 1,
            ),
          ),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.notification.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.notification.content,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: _dismiss,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
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
}

class NotificationOverlayManager {
  static OverlayEntry? _currentOverlay;

  static void showToast(
    BuildContext context,
    NotificationMessage notification, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    // Remove existing toast if any
    removeCurrentToast();

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              onTap?.call();
              removeCurrentToast();
            },
            child: NotificationToastWidget(
              notification: notification,
              duration: duration,
              onDismiss: removeCurrentToast,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    _currentOverlay = overlayEntry;
  }

  static void removeCurrentToast() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}