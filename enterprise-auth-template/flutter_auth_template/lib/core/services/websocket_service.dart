import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../constants/api_constants.dart';
import '../errors/app_exception.dart';
import '../storage/secure_storage_service.dart';

enum WebSocketState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

enum WebSocketEventType {
  notification,
  sessionUpdate,
  userUpdate,
  systemAlert,
  deviceStatusUpdate,
  auditLog,
  organizationUpdate,
}

class WebSocketEvent {
  final WebSocketEventType type;
  final Map&lt;String, dynamic&gt; data;
  final DateTime timestamp;
  final String? userId;
  final String? organizationId;

  const WebSocketEvent({
    required this.type,
    required this.data,
    required this.timestamp,
    this.userId,
    this.organizationId,
  });

  factory WebSocketEvent.fromJson(Map&lt;String, dynamic&gt; json) {
    return WebSocketEvent(
      type: WebSocketEventType.values.firstWhere(
        (e) =&gt; e.name == json[&apos;type&apos;],
        orElse: () =&gt; WebSocketEventType.notification,
      ),
      data: json[&apos;data&apos;] ?? {},
      timestamp: DateTime.parse(json[&apos;timestamp&apos;]),
      userId: json[&apos;user_id&apos;],
      organizationId: json[&apos;organization_id&apos;],
    );
  }

  Map&lt;String, dynamic&gt; toJson() {
    return {
      &apos;type&apos;: type.name,
      &apos;data&apos;: data,
      &apos;timestamp&apos;: timestamp.toIso8601String(),
      if (userId != null) &apos;user_id&apos;: userId,
      if (organizationId != null) &apos;organization_id&apos;: organizationId,
    };
  }
}

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() =&gt; _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  final SecureStorageService _storageService = SecureStorageService();

  // State management
  final StreamController&lt;WebSocketState&gt; _stateController =
      StreamController&lt;WebSocketState&gt;.broadcast();
  final StreamController&lt;WebSocketEvent&gt; _eventController =
      StreamController&lt;WebSocketEvent&gt;.broadcast();
  final StreamController&lt;String&gt; _errorController =
      StreamController&lt;String&gt;.broadcast();

  WebSocketState _currentState = WebSocketState.disconnected;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 5);

  // Streams
  Stream&lt;WebSocketState&gt; get stateStream =&gt; _stateController.stream;
  Stream&lt;WebSocketEvent&gt; get eventStream =&gt; _eventController.stream;
  Stream&lt;String&gt; get errorStream =&gt; _errorController.stream;

  WebSocketState get currentState =&gt; _currentState;
  bool get isConnected =&gt; _currentState == WebSocketState.connected;

  /// Connect to WebSocket server
  Future&lt;void&gt; connect() async {
    if (_currentState == WebSocketState.connecting ||
        _currentState == WebSocketState.connected) {
      return;
    }

    try {
      _updateState(WebSocketState.connecting);

      // Get authentication token
      final token = await _storageService.getToken();
      if (token == null) {
        throw const AuthenticationException(&apos;No authentication token found&apos;);
      }

      // Build WebSocket URL
      final baseUrl = ApiConstants.baseUrl.replaceFirst(&apos;http&apos;, &apos;ws&apos;);
      final wsUrl = &apos;$baseUrl/ws?token=$token&apos;;

      if (kDebugMode) {
        print(&apos;Connecting to WebSocket: $wsUrl&apos;);
      }

      // Create WebSocket connection
      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
        protocols: [&apos;echo-protocol&apos;],
      );

      // Listen for messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );

      // Send connection acknowledgment
      await _sendMessage({&apos;type&apos;: &apos;connection_ack&apos;});

      _updateState(WebSocketState.connected);
      _resetReconnectAttempts();
      _startHeartbeat();

      if (kDebugMode) {
        print(&apos;WebSocket connected successfully&apos;);
      }
    } catch (e) {
      _updateState(WebSocketState.error);
      _addError(&apos;Connection failed: ${e.toString()}&apos;);
      _scheduleReconnect();
    }
  }

  /// Disconnect from WebSocket server
  Future&lt;void&gt; disconnect() async {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();

    if (_channel != null) {
      await _channel!.sink.close(status.normalClosure);
      _channel = null;
    }

    _updateState(WebSocketState.disconnected);
    _resetReconnectAttempts();

    if (kDebugMode) {
      print(&apos;WebSocket disconnected&apos;);
    }
  }

  /// Send message to WebSocket server
  Future&lt;void&gt; sendMessage(Map&lt;String, dynamic&gt; message) async {
    if (!isConnected) {
      throw const NetworkException(&apos;WebSocket not connected&apos;, null);
    }

    await _sendMessage(message);
  }

  /// Subscribe to specific event types
  Stream&lt;WebSocketEvent&gt; subscribeToEventType(WebSocketEventType type) {
    return eventStream.where((event) =&gt; event.type == type);
  }

  /// Subscribe to user-specific events
  Stream&lt;WebSocketEvent&gt; subscribeToUserEvents(String userId) {
    return eventStream.where((event) =&gt; event.userId == userId);
  }

  /// Subscribe to organization-specific events
  Stream&lt;WebSocketEvent&gt; subscribeToOrganizationEvents(String organizationId) {
    return eventStream.where(
      (event) =&gt; event.organizationId == organizationId,
    );
  }

  // Private methods

  void _handleMessage(dynamic message) {
    try {
      final data = json.decode(message as String);
      
      if (data[&apos;type&apos;] == &apos;ping&apos;) {
        _sendMessage({&apos;type&apos;: &apos;pong&apos;});
        return;
      }

      if (data[&apos;type&apos;] == &apos;pong&apos;) {
        // Heartbeat response received
        return;
      }

      final event = WebSocketEvent.fromJson(data);
      _eventController.add(event);

      if (kDebugMode) {
        print(&apos;WebSocket event received: ${event.type.name}&apos;);
      }
    } catch (e) {
      _addError(&apos;Failed to parse WebSocket message: ${e.toString()}&apos;);
    }
  }

  void _handleError(dynamic error) {
    if (kDebugMode) {
      print(&apos;WebSocket error: $error&apos;);
    }

    _updateState(WebSocketState.error);
    _addError(&apos;WebSocket error: ${error.toString()}&apos;);
    _scheduleReconnect();
  }

  void _handleDisconnect() {
    if (kDebugMode) {
      print(&apos;WebSocket disconnected&apos;);
    }

    _heartbeatTimer?.cancel();
    _channel = null;

    if (_currentState != WebSocketState.disconnected) {
      _updateState(WebSocketState.disconnected);
      _scheduleReconnect();
    }
  }

  Future&lt;void&gt; _sendMessage(Map&lt;String, dynamic&gt; message) async {
    try {
      final jsonMessage = json.encode(message);
      _channel!.sink.add(jsonMessage);
    } catch (e) {
      _addError(&apos;Failed to send WebSocket message: ${e.toString()}&apos;);
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (isConnected) {
        _sendMessage({&apos;type&apos;: &apos;ping&apos;});
      }
    });
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts &gt;= _maxReconnectAttempts) {
      _updateState(WebSocketState.error);
      _addError(&apos;Max reconnection attempts reached&apos;);
      return;
    }

    _reconnectAttempts++;
    _updateState(WebSocketState.reconnecting);

    final delay = Duration(
      seconds: _reconnectDelay.inSeconds * _reconnectAttempts,
    );

    if (kDebugMode) {
      print(&apos;Scheduling WebSocket reconnect attempt $_reconnectAttempts in ${delay.inSeconds}s&apos;);
    }

    _reconnectTimer = Timer(delay, () {
      connect();
    });
  }

  void _resetReconnectAttempts() {
    _reconnectAttempts = 0;
  }

  void _updateState(WebSocketState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _stateController.add(newState);
    }
  }

  void _addError(String error) {
    _errorController.add(error);
  }

  /// Dispose all resources
  void dispose() {
    disconnect();
    _stateController.close();
    _eventController.close();
    _errorController.close();
  }
}