import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/services/websocket_service.dart';
import '../core/errors/app_exception.dart';

part 'websocket_provider.freezed.dart';

@freezed
class WebSocketState with _$WebSocketState {
  const factory WebSocketState({
    @Default(WebSocketState.disconnected) WebSocketState connectionState,
    @Default([]) List<WebSocketEvent> recentEvents,
    @Default([]) List<WebSocketEvent> notifications,
    @Default([]) List<String> errors,
    @Default(0) int unreadNotificationCount,
    @Default(false) bool isAutoReconnectEnabled,
  }) = _WebSocketState;
}

class WebSocketNotifier extends StateNotifier<WebSocketState> {
  WebSocketNotifier() : super(const WebSocketState()) {
    _initialize();
  }

  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription<WebSocketState>? _stateSubscription;
  StreamSubscription<WebSocketEvent>? _eventSubscription;
  StreamSubscription<String>? _errorSubscription;

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
        if (updatedErrors.length > 10) {
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
    if (recentEvents.length > 50) {
      recentEvents.removeLast();
    }

    // Handle notifications specifically
    List<WebSocketEvent> notifications = state.notifications;
    int unreadCount = state.unreadNotificationCount;

    if (event.type == WebSocketEventType.notification) {
      notifications = [event, ...notifications];
      // Keep only last 100 notifications
      if (notifications.length > 100) {
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
  Future<void> connect() async {
    try {
      await _webSocketService.connect();
    } catch (e) {
      final updatedErrors = [...state.errors, 'Connection failed: ${e.toString()}'];
      state = state.copyWith(errors: updatedErrors);
    }
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    await _webSocketService.disconnect();
    state = state.copyWith(isAutoReconnectEnabled: false);
  }

  /// Send message through WebSocket
  Future<void> sendMessage(Map<String, dynamic> message) async {
    try {
      await _webSocketService.sendMessage(message);
    } catch (e) {
      final updatedErrors = [...state.errors, 'Send failed: ${e.toString()}'];
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
    if (index >= 0 && index < state.notifications.length) {
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
  List<WebSocketEvent> getEventsByType(WebSocketEventType type) {
    return state.recentEvents.where((event) => event.type == type).toList();
  }

  /// Get events for user
  List<WebSocketEvent> getEventsForUser(String userId) {
    return state.recentEvents.where((event) => event.userId == userId).toList();
  }

  /// Get events for organization
  List<WebSocketEvent> getEventsForOrganization(String organizationId) {
    return state.recentEvents
        .where((event) => event.organizationId == organizationId)
        .toList();
  }

  /// Subscribe to specific event types
  Stream<WebSocketEvent> subscribeToEventType(WebSocketEventType type) {
    return _webSocketService.subscribeToEventType(type);
  }

  /// Subscribe to user events
  Stream<WebSocketEvent> subscribeToUserEvents(String userId) {
    return _webSocketService.subscribeToUserEvents(userId);
  }

  /// Subscribe to organization events
  Stream<WebSocketEvent> subscribeToOrganizationEvents(String organizationId) {
    return _webSocketService.subscribeToOrganizationEvents(organizationId);
  }

  /// Check if WebSocket is connected
  bool get isConnected => _webSocketService.isConnected;

  /// Get current connection state
  WebSocketState get connectionState => _webSocketService.currentState;

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
final webSocketProvider = StateNotifierProvider<WebSocketNotifier, WebSocketState>(
  (ref) => WebSocketNotifier(),
);

// Specific stream providers for different event types
final notificationStreamProvider = StreamProvider<WebSocketEvent>((ref) {
  final webSocketService = WebSocketService();
  return webSocketService.subscribeToEventType(WebSocketEventType.notification);
});

final sessionUpdateStreamProvider = StreamProvider<WebSocketEvent>((ref) {
  final webSocketService = WebSocketService();
  return webSocketService.subscribeToEventType(WebSocketEventType.sessionUpdate);
});

final userUpdateStreamProvider = StreamProvider<WebSocketEvent>((ref) {
  final webSocketService = WebSocketService();
  return webSocketService.subscribeToEventType(WebSocketEventType.userUpdate);
});

final systemAlertStreamProvider = StreamProvider<WebSocketEvent>((ref) {
  final webSocketService = WebSocketService();
  return webSocketService.subscribeToEventType(WebSocketEventType.systemAlert);
});

final deviceStatusStreamProvider = StreamProvider<WebSocketEvent>((ref) {
  final webSocketService = WebSocketService();
  return webSocketService.subscribeToEventType(WebSocketEventType.deviceStatusUpdate);
});

final auditLogStreamProvider = StreamProvider<WebSocketEvent>((ref) {
  final webSocketService = WebSocketService();
  return webSocketService.subscribeToEventType(WebSocketEventType.auditLog);
});

final organizationUpdateStreamProvider = StreamProvider<WebSocketEvent>((ref) {
  final webSocketService = WebSocketService();
  return webSocketService.subscribeToEventType(WebSocketEventType.organizationUpdate);
});

// Helper providers
final unreadNotificationCountProvider = Provider<int>((ref) {
  final webSocketState = ref.watch(webSocketProvider);
  return webSocketState.unreadNotificationCount;
});

final isWebSocketConnectedProvider = Provider<bool>((ref) {
  final webSocketState = ref.watch(webSocketProvider);
  return webSocketState.connectionState == WebSocketState.connected;
});

final recentWebSocketErrorsProvider = Provider<List<String>>((ref) {
  final webSocketState = ref.watch(webSocketProvider);
  return webSocketState.errors;
});