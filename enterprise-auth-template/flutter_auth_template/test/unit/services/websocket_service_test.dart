import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_auth_template/core/services/websocket_service.dart';
import 'dart:async';
import 'dart:convert';

@GenerateMocks([WebSocketChannel])
import 'websocket_service_test.mocks.dart';

void main() {
  group('WebSocketService', () {
    late WebSocketService webSocketService;
    late MockWebSocketChannel mockChannel;
    late StreamController<dynamic> mockStream;

    setUp(() {
      mockChannel = MockWebSocketChannel();
      mockStream = StreamController<dynamic>.broadcast();
      webSocketService = WebSocketService();
      
      when(mockChannel.stream).thenAnswer((_) => mockStream.stream);
      when(mockChannel.sink).thenReturn(MockWebSocketSink());
    });

    tearDown(() {
      mockStream.close();
      webSocketService.dispose();
    });

    group('Connection Management', () {
      test('should start with disconnected state', () {
        expect(webSocketService.isConnected, isFalse);
        expect(webSocketService.connectionState, WebSocketConnectionState.disconnected);
      });

      test('should emit connection state changes', () async {
        final states = <WebSocketConnectionState>[];
        webSocketService.connectionStateStream.listen((state) {
          states.add(state);
        });

        // Mock successful connection
        when(mockChannel.stream).thenAnswer((_) => Stream.value('{"type":"connection_ack"}'));
        
        await webSocketService.connect('ws://test.com', 'test-token');
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(states, contains(WebSocketConnectionState.connecting));
      });

      test('should authenticate after connection', () async {
        final sentMessages = <String>[];
        final mockSink = MockWebSocketSink();
        when(mockChannel.sink).thenReturn(mockSink);
        when(mockSink.add(any)).thenAnswer((invocation) {
          sentMessages.add(invocation.positionalArguments[0] as String);
        });

        when(mockChannel.stream).thenAnswer((_) => Stream.value('{"type":"connection_ack"}'));
        
        await webSocketService.connect('ws://test.com', 'test-token');
        
        expect(sentMessages, isNotEmpty);
        final authMessage = json.decode(sentMessages.first);
        expect(authMessage['type'], 'connection_init');
        expect(authMessage['payload']['token'], 'test-token');
      });

      test('should handle connection failures', () async {
        final errors = <String>[];
        webSocketService.errorStream.listen((error) {
          errors.add(error.message);
        });

        when(mockChannel.stream)
            .thenAnswer((_) => Stream.error(Exception('Connection failed')));
        
        await webSocketService.connect('ws://invalid-url', 'token');
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(errors, isNotEmpty);
        expect(webSocketService.connectionState, WebSocketConnectionState.error);
      });
    });

    group('Message Handling', () {
      test('should parse and route messages correctly', () async {
        final messages = <WebSocketMessage>[];
        webSocketService.messageStream.listen((message) {
          messages.add(message);
        });

        final testMessage = {
          'type': 'notification',
          'data': {'id': '123', 'title': 'Test Notification'}
        };

        mockStream.add(json.encode(testMessage));
        
        await Future.delayed(const Duration(milliseconds: 50));
        
        expect(messages, hasLength(1));
        expect(messages.first.type, 'notification');
        expect(messages.first.data['id'], '123');
      });

      test('should handle malformed messages gracefully', () async {
        final errors = <WebSocketError>[];
        webSocketService.errorStream.listen((error) {
          errors.add(error);
        });

        mockStream.add('invalid json');
        
        await Future.delayed(const Duration(milliseconds: 50));
        
        expect(errors, hasLength(1));
        expect(errors.first.type, WebSocketErrorType.messageParsingError);
      });

      test('should filter messages by type', () async {
        final notificationMessages = <WebSocketMessage>[];
        webSocketService.getMessagesOfType('notification').listen((message) {
          notificationMessages.add(message);
        });

        // Send different message types
        mockStream.add(json.encode({'type': 'notification', 'data': {'id': '1'}}));
        mockStream.add(json.encode({'type': 'user_update', 'data': {'id': '2'}}));
        mockStream.add(json.encode({'type': 'notification', 'data': {'id': '3'}}));
        
        await Future.delayed(const Duration(milliseconds: 50));
        
        expect(notificationMessages, hasLength(2));
        expect(notificationMessages.first.data['id'], '1');
        expect(notificationMessages.last.data['id'], '3');
      });
    });

    group('Subscription Management', () {
      test('should manage subscriptions', () async {
        final mockSink = MockWebSocketSink();
        final sentMessages = <String>[];
        
        when(mockChannel.sink).thenReturn(mockSink);
        when(mockSink.add(any)).thenAnswer((invocation) {
          sentMessages.add(invocation.positionalArguments[0] as String);
        });

        await webSocketService.subscribe('user_notifications');
        
        expect(sentMessages, hasLength(1));
        final message = json.decode(sentMessages.first);
        expect(message['type'], 'subscribe');
        expect(message['subscription'], 'user_notifications');
        expect(webSocketService.activeSubscriptions, contains('user_notifications'));
      });

      test('should unsubscribe properly', () async {
        final mockSink = MockWebSocketSink();
        final sentMessages = <String>[];
        
        when(mockChannel.sink).thenReturn(mockSink);
        when(mockSink.add(any)).thenAnswer((invocation) {
          sentMessages.add(invocation.positionalArguments[0] as String);
        });

        await webSocketService.subscribe('test_subscription');
        await webSocketService.unsubscribe('test_subscription');
        
        expect(sentMessages, hasLength(2));
        final unsubscribeMessage = json.decode(sentMessages.last);
        expect(unsubscribeMessage['type'], 'unsubscribe');
        expect(webSocketService.activeSubscriptions, isNot(contains('test_subscription')));
      });

      test('should clear all subscriptions on disconnect', () async {
        await webSocketService.subscribe('sub1');
        await webSocketService.subscribe('sub2');
        
        expect(webSocketService.activeSubscriptions, hasLength(2));
        
        webSocketService.disconnect();
        
        expect(webSocketService.activeSubscriptions, isEmpty);
      });
    });

    group('Heartbeat Mechanism', () {
      test('should send periodic heartbeat messages', () async {
        final mockSink = MockWebSocketSink();
        final sentMessages = <String>[];
        
        when(mockChannel.sink).thenReturn(mockSink);
        when(mockSink.add(any)).thenAnswer((invocation) {
          sentMessages.add(invocation.positionalArguments[0] as String);
        });

        // Mock connection established
        when(mockChannel.stream).thenAnswer((_) => Stream.value('{"type":"connection_ack"}'));
        
        await webSocketService.connect('ws://test.com', 'token');
        
        // Wait for heartbeat interval
        await Future.delayed(const Duration(seconds: 31));
        
        final heartbeatMessages = sentMessages.where((msg) {
          final parsed = json.decode(msg);
          return parsed['type'] == 'ping';
        }).toList();
        
        expect(heartbeatMessages, isNotEmpty);
      });

      test('should handle pong responses', () async {
        final pongMessage = {'type': 'pong', 'timestamp': DateTime.now().millisecondsSinceEpoch};
        
        mockStream.add(json.encode(pongMessage));
        
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Should not generate error or disconnect
        expect(webSocketService.connectionState, isNot(WebSocketConnectionState.error));
      });
    });

    group('Reconnection Logic', () {
      test('should attempt reconnection on connection loss', () async {
        int connectionAttempts = 0;
        
        // Override connect method to count attempts
        webSocketService.connect('ws://test.com', 'token').catchError((_) {
          connectionAttempts++;
          return;
        });

        // Simulate connection loss
        mockStream.addError(Exception('Connection lost'));
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        expect(connectionAttempts, greaterThan(0));
      });

      test('should respect max reconnection attempts', () async {
        int errorCount = 0;
        webSocketService.errorStream.listen((error) {
          if (error.type == WebSocketErrorType.maxReconnectAttemptsReached) {
            errorCount++;
          }
        });

        // Simulate repeated connection failures
        for (int i = 0; i < 10; i++) {
          mockStream.addError(Exception('Connection failed'));
          await Future.delayed(const Duration(milliseconds: 100));
        }
        
        expect(errorCount, greaterThan(0));
      });
    });

    group('Custom Message Sending', () {
      test('should send custom messages', () async {
        final mockSink = MockWebSocketSink();
        final sentMessages = <String>[];
        
        when(mockChannel.sink).thenReturn(mockSink);
        when(mockSink.add(any)).thenAnswer((invocation) {
          sentMessages.add(invocation.positionalArguments[0] as String);
        });

        final customData = {'action': 'update_profile', 'data': {'name': 'John Doe'}};
        
        await webSocketService.sendMessage('custom_action', customData);
        
        expect(sentMessages, hasLength(1));
        final message = json.decode(sentMessages.first);
        expect(message['type'], 'custom_action');
        expect(message['data'], customData);
      });

      test('should queue messages when disconnected', () async {
        final customData = {'test': 'data'};
        
        // Send message while disconnected
        await webSocketService.sendMessage('test_message', customData);
        
        final mockSink = MockWebSocketSink();
        final sentMessages = <String>[];
        
        when(mockChannel.sink).thenReturn(mockSink);
        when(mockSink.add(any)).thenAnswer((invocation) {
          sentMessages.add(invocation.positionalArguments[0] as String);
        });

        // Connect and check if queued message is sent
        when(mockChannel.stream).thenAnswer((_) => Stream.value('{"type":"connection_ack"}'));
        await webSocketService.connect('ws://test.com', 'token');
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        final testMessages = sentMessages.where((msg) {
          final parsed = json.decode(msg);
          return parsed['type'] == 'test_message';
        }).toList();
        
        expect(testMessages, hasLength(1));
      });
    });
  });
}

class MockWebSocketSink extends Mock implements WebSocketSink {
  @override
  void add(data) => super.noSuchMethod(Invocation.method(#add, [data]));
  
  @override
  Future close([int? code, String? reason]) async {
    return super.noSuchMethod(
      Invocation.method(#close, [code, reason]),
      returnValue: Future.value(),
    );
  }
}