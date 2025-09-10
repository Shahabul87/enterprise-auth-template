import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/services/websocket_service.dart';
import '../core/errors/app_exception.dart';

part &apos;websocket_provider.freezed.dart&apos;;

@freezed
class WebSocketState with _$WebSocketState {
  const factory WebSocketState({
    @Default(WebSocketState.disconnected) WebSocketState connectionState,
    @Default([]) List&lt;WebSocketEvent&gt; recentEvents,
    @Default([]) List&lt;WebSocketEvent&gt; notifications,
    @Default([]) List&lt;String&gt; errors,
    @Default(0) int unreadNotificationCount,
    @Default(false) bool isAutoReconnectEnabled,
  }) = _WebSocketState;
}

class WebSocketNotifier extends StateNotifier&lt;WebSocketState&gt; {
  WebSocketNotifier() : super(const WebSocketState()) {
    _initialize();
  }

  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription&lt;WebSocketState&gt;? _stateSubscription;
  StreamSubscription&lt;WebSocketEvent&gt;? _eventSubscription;
  StreamSubscription&lt;String&gt;? _errorSubscription;

  void _initialize() {
    // Listen to connection state changes
    _stateSubscription = _webSocketService.stateStream.listen(
      (connectionState) {
        state = state.copyWith(connectionState: connectionState);
      },
    );

    // Listen to WebSocket events
    _eventSubscription = _webSocketService.eventStream.listen(
      (event) {
        _handleWebSocketEvent(event);
      },
    );

    // Listen to errors
    _errorSubscription = _webSocketService.errorStream.listen(
      (error) {
        final updatedErrors = [...state.errors, error];
        // Keep only last 10 errors
        if (updatedErrors.length &gt; 10) {
          updatedErrors.removeAt(0);
        }
        state = state.copyWith(errors: updatedErrors);
      },
    );
  }

  void _handleWebSocketEvent(WebSocketEvent event) {
    // Add to recent events
    final recentEvents = [event, ...state.recentEvents];
    // Keep only last 50 events
    if (recentEvents.length &gt; 50) {
      recentEvents.removeLast();
    }

    // Handle notifications specifically
    List&lt;WebSocketEvent&gt; notifications = state.notifications;
    int unreadCount = state.unreadNotificationCount;

    if (event.type == WebSocketEventType.notification) {
      notifications = [event, ...notifications];
      // Keep only last 100 notifications
      if (notifications.length &gt; 100) {
        notifications.removeLast();
      }
      unreadCount++;
    }

    state = state.copyWith(
      recentEvents: recentEvents,
      notifications: notifications,
      unreadNotificationCount: unreadCount,
    );
  }

  /// Connect to WebSocket
  Future&lt;void&gt; connect() async {
    try {
      await _webSocketService.connect();
    } catch (e) {
      final updatedErrors = [...state.errors, &apos;Connection failed: ${e.toString()}&apos;];
      state = state.copyWith(errors: updatedErrors);
    }
  }

  /// Disconnect from WebSocket
  Future&lt;void&gt; disconnect() async {
    await _webSocketService.disconnect();
    state = state.copyWith(isAutoReconnectEnabled: false);
  }

  /// Send message through WebSocket
  Future&lt;void&gt; sendMessage(Map&lt;String, dynamic&gt; message) async {
    try {
      await _webSocketService.sendMessage(message);
    } catch (e) {
      final updatedErrors = [...state.errors, &apos;Send failed: ${e.toString()}&apos;];
      state = state.copyWith(errors: updatedErrors);
    }
  }

  /// Toggle auto-reconnect
  void toggleAutoReconnect() {
    state = state.copyWith(isAutoReconnectEnabled: !state.isAutoReconnectEnabled);
  }

  /// Mark notifications as read
  void markNotificationsAsRead() {
    state = state.copyWith(unreadNotificationCount: 0);
  }

  /// Clear specific notification
  void clearNotification(int index) {
    if (index &gt;= 0 &amp;&amp; index &lt; state.notifications.length) {
      final notifications = [...state.notifications];
      notifications.removeAt(index);
      state = state.copyWith(notifications: notifications);
    }
  }

  /// Clear all notifications
  void clearAllNotifications() {
    state = state.copyWith(
      notifications: [],
      unreadNotificationCount: 0,
    );
  }

  /// Clear recent events
  void clearRecentEvents() {
    state = state.copyWith(recentEvents: []);
  }

  /// Clear errors
  void clearErrors() {
    state = state.copyWith(errors: []);
  }

  /// Get events by type
  List&lt;WebSocketEvent&gt; getEventsByType(WebSocketEventType type) {
    return state.recentEvents.where((event) =&gt; event.type == type).toList();
  }

  /// Get events for user
  List&lt;WebSocketEvent&gt; getEventsForUser(String userId) {
    return state.recentEvents.where((event) =&gt; event.userId == userId).toList();
  }

  /// Get events for organization
  List&lt;WebSocketEvent&gt; getEventsForOrganization(String organizationId) {
    return state.recentEvents
        .where((event) =&gt; event.organizationId == organizationId)
        .toList();
  }

  /// Subscribe to specific event types
  Stream&lt;WebSocketEvent&gt; subscribeToEventType(WebSocketEventType type) {
    return _webSocketService.subscribeToEventType(type);
  }

  /// Subscribe to user events
  Stream&lt;WebSocketEvent&gt; subscribeToUserEvents(String userId) {
    return _webSocketService.subscribeToUserEvents(userId);
  }

  /// Subscribe to organization events
  Stream&lt;WebSocketEvent&gt; subscribeToOrganizationEvents(String organizationId) {
    return _webSocketService.subscribeToOrganizationEvents(organizationId);
  }

  /// Check if WebSocket is connected
  bool get isConnected =&gt; _webSocketService.isConnected;

  /// Get current connection state
  WebSocketState get connectionState =&gt; _webSocketService.currentState;

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _eventSubscription?.cancel();
    _errorSubscription?.cancel();
    _webSocketService.dispose();
    super.dispose();
  }
}

// Provider definitions
final webSocketProvider = StateNotifierProvider&lt;WebSocketNotifier, WebSocketState&gt;(
  (ref) =&gt; WebSocketNotifier(),
);

// Specific stream providers for different event types
final notificationStreamProvider = StreamProvider&lt;WebSocketEvent&gt;((ref) {
  final webSocketService = WebSocketService();
  return webSocketService.subscribeToEventType(WebSocketEventType.notification);
});

final sessionUpdateStreamProvider = StreamProvider&lt;WebSocketEvent&gt;((ref) {
  final webSocketService = WebSocketService();
  return webSocketService.subscribeToEventType(WebSocketEventType.sessionUpdate);
});

final userUpdateStreamProvider = StreamProvider&lt;WebSocketEvent&gt;((ref) {
  final webSocketService = WebSocketService();
  return webSocketService.subscribeToEventType(WebSocketEventType.userUpdate);
});

final systemAlertStreamProvider = StreamProvider&lt;WebSocketEvent&gt;((ref) {
  final webSocketService = WebSocketService();
  return webSocketService.subscribeToEventType(WebSocketEventType.systemAlert);
});

final deviceStatusStreamProvider = StreamProvider&lt;WebSocketEvent&gt;((ref) {
  final webSocketService = WebSocketService();
  return webSocketService.subscribeToEventType(WebSocketEventType.deviceStatusUpdate);
});

final auditLogStreamProvider = StreamProvider&lt;WebSocketEvent&gt;((ref) {
  final webSocketService = WebSocketService();
  return webSocketService.subscribeToEventType(WebSocketEventType.auditLog);
});

final organizationUpdateStreamProvider = StreamProvider&lt;WebSocketEvent&gt;((ref) {
  final webSocketService = WebSocketService();
  return webSocketService.subscribeToEventType(WebSocketEventType.organizationUpdate);
});

// Helper providers
final unreadNotificationCountProvider = Provider&lt;int&gt;((ref) {
  final webSocketState = ref.watch(webSocketProvider);
  return webSocketState.unreadNotificationCount;
});

final isWebSocketConnectedProvider = Provider&lt;bool&gt;((ref) {
  final webSocketState = ref.watch(webSocketProvider);
  return webSocketState.connectionState == WebSocketState.connected;
});

final recentWebSocketErrorsProvider = Provider&lt;List&lt;String&gt;&gt;((ref) {
  final webSocketState = ref.watch(webSocketProvider);
  return webSocketState.errors;
});