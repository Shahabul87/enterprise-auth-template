import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_auth_template/core/services/websocket_service.dart' as ws;
import 'package:flutter_auth_template/core/errors/app_exception.dart';

part 'websocket_provider.freezed.dart';

@freezed
class WebSocketProviderState with _$WebSocketProviderState {
  const factory WebSocketProviderState({
    @Default(ws.WebSocketState.disconnected) ws.WebSocketState connectionState,
    @Default([]) List<ws.WebSocketEvent> recentEvents,
    @Default([]) List<ws.WebSocketEvent> notifications,
    @Default([]) List<String> errors,
    @Default(0) int unreadNotificationCount,
    @Default(false) bool isAutoReconnectEnabled,
  }) = _WebSocketProviderState;
}

class WebSocketNotifier extends StateNotifier<WebSocketProviderState> {
  WebSocketNotifier() : super(const WebSocketProviderState()) {
    _initialize();
  }

  final ws.WebSocketService _webSocketService = ws.WebSocketService();
  StreamSubscription<ws.WebSocketState>? _stateSubscription;
  StreamSubscription<ws.WebSocketEvent>? _eventSubscription;
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

  void _handleWebSocketEvent(ws.WebSocketEvent event) {
    // Add to recent events
    final recentEvents = [event, ...state.recentEvents];
    // Keep only last 50 events
    if (recentEvents.length > 50) {
      recentEvents.removeLast();
    }

    // Handle notifications specifically
    List<ws.WebSocketEvent> notifications = state.notifications;
    int unreadCount = state.unreadNotificationCount;

    if (event.type == ws.WebSocketEventType.notification) {
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
  List<ws.WebSocketEvent> getEventsByType(ws.WebSocketEventType type) {
    return state.recentEvents.where((event) => event.type == type).toList();
  }

  /// Get events for user
  List<ws.WebSocketEvent> getEventsForUser(String userId) {
    return state.recentEvents.where((event) => event.userId == userId).toList();
  }

  /// Get events for organization
  List<ws.WebSocketEvent> getEventsForOrganization(String organizationId) {
    return state.recentEvents
        .where((event) => event.organizationId == organizationId)
        .toList();
  }

  /// Subscribe to specific event types
  Stream<ws.WebSocketEvent> subscribeToEventType(ws.WebSocketEventType type) {
    return _webSocketService.subscribeToEventType(type);
  }

  /// Subscribe to user events
  Stream<ws.WebSocketEvent> subscribeToUserEvents(String userId) {
    return _webSocketService.subscribeToUserEvents(userId);
  }

  /// Subscribe to organization events
  Stream<ws.WebSocketEvent> subscribeToOrganizationEvents(String organizationId) {
    return _webSocketService.subscribeToOrganizationEvents(organizationId);
  }

  /// Check if WebSocket is connected
  bool get isConnected => _webSocketService.isConnected;

  /// Get current connection state
  ws.WebSocketState get connectionState => _webSocketService.currentState;

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _eventSubscription?.cancel();
    _errorSubscription?.cancel();
    _webSocketService.dispose();
    super.dispose();
  }
}

// Service provider
final webSocketServiceProvider = Provider<ws.WebSocketService>((ref) {
  return ws.WebSocketService();
});

// Provider definitions
final webSocketProvider = StateNotifierProvider<WebSocketNotifier, WebSocketProviderState>(
  (ref) => WebSocketNotifier(),
);

// Specific stream providers for different event types
final notificationStreamProvider = StreamProvider<ws.WebSocketEvent>((ref) {
  final webSocketService = ref.read(webSocketServiceProvider);
  return webSocketService.subscribeToEventType(ws.WebSocketEventType.notification);
});

final sessionUpdateStreamProvider = StreamProvider<ws.WebSocketEvent>((ref) {
  final webSocketService = ref.read(webSocketServiceProvider);
  return webSocketService.subscribeToEventType(ws.WebSocketEventType.sessionUpdate);
});

final userUpdateStreamProvider = StreamProvider<ws.WebSocketEvent>((ref) {
  final webSocketService = ref.read(webSocketServiceProvider);
  return webSocketService.subscribeToEventType(ws.WebSocketEventType.userUpdate);
});

final systemAlertStreamProvider = StreamProvider<ws.WebSocketEvent>((ref) {
  final webSocketService = ref.read(webSocketServiceProvider);
  return webSocketService.subscribeToEventType(ws.WebSocketEventType.systemAlert);
});

final deviceStatusStreamProvider = StreamProvider<ws.WebSocketEvent>((ref) {
  final webSocketService = ref.read(webSocketServiceProvider);
  return webSocketService.subscribeToEventType(ws.WebSocketEventType.deviceStatusUpdate);
});

final auditLogStreamProvider = StreamProvider<ws.WebSocketEvent>((ref) {
  final webSocketService = ref.read(webSocketServiceProvider);
  return webSocketService.subscribeToEventType(ws.WebSocketEventType.auditLog);
});

final organizationUpdateStreamProvider = StreamProvider<ws.WebSocketEvent>((ref) {
  final webSocketService = ref.read(webSocketServiceProvider);
  return webSocketService.subscribeToEventType(ws.WebSocketEventType.organizationUpdate);
});

// Helper providers
final unreadNotificationCountProvider = Provider<int>((ref) {
  final webSocketState = ref.watch(webSocketProvider);
  return webSocketState.unreadNotificationCount;
});

final isWebSocketConnectedProvider = Provider<bool>((ref) {
  final webSocketState = ref.watch(webSocketProvider);
  return webSocketState.connectionState == ws.WebSocketState.connected;
});

final recentWebSocketErrorsProvider = Provider<List<String>>((ref) {
  final webSocketState = ref.watch(webSocketProvider);
  return webSocketState.errors;
});