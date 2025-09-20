import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import 'package:flutter_auth_template/core/constants/api_constants.dart';
import 'package:flutter_auth_template/core/errors/app_exception.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';

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
  final Map<String, dynamic> data;
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

  factory WebSocketEvent.fromJson(Map<String, dynamic> json) {
    return WebSocketEvent(
      type: WebSocketEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WebSocketEventType.notification,
      ),
      data: json['data'] ?? {},
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['user_id'],
      organizationId: json['organization_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      if (userId != null) 'user_id': userId,
      if (organizationId != null) 'organization_id': organizationId,
    };
  }
}

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  final SecureStorageService _storageService = SecureStorageService();

  // State management
  final StreamController<WebSocketState> _stateController =
      StreamController<WebSocketState>.broadcast();
  final StreamController<WebSocketEvent> _eventController =
      StreamController<WebSocketEvent>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  WebSocketState _currentState = WebSocketState.disconnected;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 5);

  // Streams
  Stream<WebSocketState> get stateStream => _stateController.stream;
  Stream<WebSocketEvent> get eventStream => _eventController.stream;
  Stream<String> get errorStream => _errorController.stream;

  WebSocketState get currentState => _currentState;
  bool get isConnected => _currentState == WebSocketState.connected;

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_currentState == WebSocketState.connecting ||
        _currentState == WebSocketState.connected) {
      return;
    }

    try {
      _updateState(WebSocketState.connecting);

      // Get authentication token
      final token = await _storageService.getToken();
      if (token == null) {
        throw const UnauthorizedException('No authentication token found', null);
      }

      // Build WebSocket URL
      final baseUrl = ApiConstants.baseUrl.replaceFirst('http', 'ws');
      final wsUrl = '$baseUrl/ws?token=$token';

      if (kDebugMode) {
        print('Connecting to WebSocket: $wsUrl');
      }

      // Create WebSocket connection
      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
        protocols: ['echo-protocol'],
      );

      // Listen for messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );

      // Send connection acknowledgment
      await _sendMessage({'type': 'connection_ack'});

      _updateState(WebSocketState.connected);
      _resetReconnectAttempts();
      _startHeartbeat();

      if (kDebugMode) {
        print('WebSocket connected successfully');
      }
    } catch (e) {
      _updateState(WebSocketState.error);
      _addError('Connection failed: ${e.toString()}');
      _scheduleReconnect();
    }
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();

    if (_channel != null) {
      await _channel!.sink.close(status.normalClosure);
      _channel = null;
    }

    _updateState(WebSocketState.disconnected);
    _resetReconnectAttempts();

    if (kDebugMode) {
      print('WebSocket disconnected');
    }
  }

  /// Send message to WebSocket server
  Future<void> sendMessage(Map<String, dynamic> message) async {
    if (!isConnected) {
      throw const NetworkException('WebSocket not connected', null);
    }

    await _sendMessage(message);
  }

  /// Subscribe to specific event types
  Stream<WebSocketEvent> subscribeToEventType(WebSocketEventType type) {
    return eventStream.where((event) => event.type == type);
  }

  /// Subscribe to user-specific events
  Stream<WebSocketEvent> subscribeToUserEvents(String userId) {
    return eventStream.where((event) => event.userId == userId);
  }

  /// Subscribe to organization-specific events
  Stream<WebSocketEvent> subscribeToOrganizationEvents(String organizationId) {
    return eventStream.where(
      (event) => event.organizationId == organizationId,
    );
  }

  // Private methods

  void _handleMessage(dynamic message) {
    try {
      final data = json.decode(message as String);
      
      if (data['type'] == 'ping') {
        _sendMessage({'type': 'pong'});
        return;
      }

      if (data['type'] == 'pong') {
        // Heartbeat response received
        return;
      }

      final event = WebSocketEvent.fromJson(data);
      _eventController.add(event);

      if (kDebugMode) {
        print('WebSocket event received: ${event.type.name}');
      }
    } catch (e) {
      _addError('Failed to parse WebSocket message: ${e.toString()}');
    }
  }

  void _handleError(dynamic error) {
    if (kDebugMode) {
      print('WebSocket error: $error');
    }

    _updateState(WebSocketState.error);
    _addError('WebSocket error: ${error.toString()}');
    _scheduleReconnect();
  }

  void _handleDisconnect() {
    if (kDebugMode) {
      print('WebSocket disconnected');
    }

    _heartbeatTimer?.cancel();
    _channel = null;

    if (_currentState != WebSocketState.disconnected) {
      _updateState(WebSocketState.disconnected);
      _scheduleReconnect();
    }
  }

  Future<void> _sendMessage(Map<String, dynamic> message) async {
    try {
      final jsonMessage = json.encode(message);
      _channel!.sink.add(jsonMessage);
    } catch (e) {
      _addError('Failed to send WebSocket message: ${e.toString()}');
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (isConnected) {
        _sendMessage({'type': 'ping'});
      }
    });
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _updateState(WebSocketState.error);
      _addError('Max reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;
    _updateState(WebSocketState.reconnecting);

    final delay = Duration(
      seconds: _reconnectDelay.inSeconds * _reconnectAttempts,
    );

    if (kDebugMode) {
      print('Scheduling WebSocket reconnect attempt $_reconnectAttempts in ${delay.inSeconds}s');
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