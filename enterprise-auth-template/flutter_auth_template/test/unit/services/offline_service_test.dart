import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_auth_template/core/services/offline_service.dart';

@GenerateMocks([Connectivity, SharedPreferences])
import 'offline_service_test.mocks.dart';

void main() {
  group('OfflineService', () {
    late OfflineService offlineService;
    late MockConnectivity mockConnectivity;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockConnectivity = MockConnectivity();
      mockPrefs = MockSharedPreferences();
      offlineService = OfflineService();
      
      // Setup SharedPreferences mock defaults
      when(mockPrefs.getStringList(any)).thenReturn([]);
      when(mockPrefs.setStringList(any, any)).thenAnswer((_) async => true);
      when(mockPrefs.getString(any)).thenReturn(null);
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
      when(mockPrefs.remove(any)).thenAnswer((_) async => true);
      when(mockPrefs.getKeys()).thenReturn(<String>{});
      
      SharedPreferences.setMockInitialValues({});
    });

    group('Connectivity Management', () {
      test('should initialize with online status', () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        
        await offlineService.initialize();
        
        expect(offlineService.currentStatus, ConnectivityStatus.online);
        expect(offlineService.isOnline, isTrue);
        expect(offlineService.isOffline, isFalse);
      });

      test('should detect offline status', () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.none);
        
        await offlineService.initialize();
        
        expect(offlineService.currentStatus, ConnectivityStatus.offline);
        expect(offlineService.isOnline, isFalse);
        expect(offlineService.isOffline, isTrue);
      });

      test('should detect limited connectivity', () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.bluetooth);
        
        await offlineService.initialize();
        
        expect(offlineService.currentStatus, ConnectivityStatus.limited);
      });
    });

    group('Pending Actions', () {
      test('should add pending action', () async {
        await offlineService.initialize();
        
        final action = PendingAction(
          id: 'test-1',
          type: OfflineActionType.create,
          endpoint: '/api/test',
          data: {'test': 'data'},
          timestamp: DateTime.now(),
        );
        
        await offlineService.addPendingAction(action);
        
        expect(offlineService.pendingActions, contains(action));
        expect(offlineService.pendingActions.length, 1);
      });

      test('should queue action with proper parameters', () async {
        await offlineService.initialize();
        
        await offlineService.queueAction(
          OfflineActionType.update,
          '/api/users/123',
          {'name': 'Updated Name'},
          headers: {'Authorization': 'Bearer token'},
        );
        
        expect(offlineService.pendingActions.length, 1);
        final action = offlineService.pendingActions.first;
        expect(action.type, OfflineActionType.update);
        expect(action.endpoint, '/api/users/123');
        expect(action.data, {'name': 'Updated Name'});
        expect(action.headers, {'Authorization': 'Bearer token'});
      });

      test('should clear all pending actions', () async {
        await offlineService.initialize();
        
        // Add some actions
        await offlineService.queueAction(
          OfflineActionType.create,
          '/api/test1',
          {'data': 'test1'},
        );
        await offlineService.queueAction(
          OfflineActionType.update,
          '/api/test2',
          {'data': 'test2'},
        );
        
        expect(offlineService.pendingActions.length, 2);
        
        await offlineService.clearPendingActions();
        
        expect(offlineService.pendingActions.length, 0);
      });

      test('should find pending actions for endpoint', () async {
        await offlineService.initialize();
        
        await offlineService.queueAction(
          OfflineActionType.create,
          '/api/users',
          {'name': 'User 1'},
        );
        await offlineService.queueAction(
          OfflineActionType.update,
          '/api/posts',
          {'title': 'Post 1'},
        );
        await offlineService.queueAction(
          OfflineActionType.delete,
          '/api/users',
          {'id': '123'},
        );
        
        final userActions = await offlineService.getPendingActionsForEndpoint('/api/users');
        expect(userActions.length, 2);
        
        final hasUserActions = await offlineService.hasPendingActionsForEndpoint('/api/users');
        expect(hasUserActions, isTrue);
        
        final hasCommentActions = await offlineService.hasPendingActionsForEndpoint('/api/comments');
        expect(hasCommentActions, isFalse);
      });
    });

    group('Cache Management', () {
      test('should cache and retrieve data', () async {
        await offlineService.initialize();
        
        const key = 'test-cache-key';
        final data = {'cached': 'data', 'timestamp': 123456789};
        
        await offlineService.cacheData(key, data);
        
        final retrieved = await offlineService.getCachedData(key);
        expect(retrieved, isNotNull);
        expect(retrieved!['cached'], 'data');
      });

      test('should respect cache max age', () async {
        await offlineService.initialize();
        
        const key = 'expired-cache';
        final data = {'old': 'data'};
        
        await offlineService.cacheData(key, data);
        
        // Should return data with no max age
        final fresh = await offlineService.getCachedData(key);
        expect(fresh, isNotNull);
        
        // Should return null with very short max age
        await Future.delayed(const Duration(milliseconds: 10));
        final expired = await offlineService.getCachedData(
          key,
          maxAge: const Duration(milliseconds: 5),
        );
        expect(expired, isNull);
      });

      test('should clear cache by pattern', () async {
        await offlineService.initialize();
        
        await offlineService.cacheData('user-cache-1', {'user': 1});
        await offlineService.cacheData('user-cache-2', {'user': 2});
        await offlineService.cacheData('post-cache-1', {'post': 1});
        
        await offlineService.clearCache(keyPattern: 'user');
        
        final userCache1 = await offlineService.getCachedData('user-cache-1');
        final userCache2 = await offlineService.getCachedData('user-cache-2');
        final postCache1 = await offlineService.getCachedData('post-cache-1');
        
        expect(userCache1, isNull);
        expect(userCache2, isNull);
        expect(postCache1, isNotNull);
      });
    });

    group('PendingAction Model', () {
      test('should serialize to/from JSON', () {
        final timestamp = DateTime.now();
        final action = PendingAction(
          id: 'test-action',
          type: OfflineActionType.create,
          endpoint: '/api/test',
          data: {'key': 'value'},
          timestamp: timestamp,
          retryCount: 2,
          headers: {'Authorization': 'Bearer token'},
        );
        
        final json = action.toJson();
        final reconstructed = PendingAction.fromJson(json);
        
        expect(reconstructed.id, action.id);
        expect(reconstructed.type, action.type);
        expect(reconstructed.endpoint, action.endpoint);
        expect(reconstructed.data, action.data);
        expect(reconstructed.timestamp, action.timestamp);
        expect(reconstructed.retryCount, action.retryCount);
        expect(reconstructed.headers, action.headers);
      });

      test('should create copy with updated values', () {
        final original = PendingAction(
          id: 'original',
          type: OfflineActionType.create,
          endpoint: '/api/original',
          data: {'original': 'data'},
          timestamp: DateTime.now(),
          retryCount: 0,
        );
        
        final copy = original.copyWith(
          retryCount: 3,
          data: {'updated': 'data'},
        );
        
        expect(copy.id, original.id);
        expect(copy.type, original.type);
        expect(copy.endpoint, original.endpoint);
        expect(copy.retryCount, 3);
        expect(copy.data, {'updated': 'data'});
      });
    });

    group('Offline Status', () {
      test('should provide comprehensive status information', () async {
        await offlineService.initialize();
        
        // Add some pending actions
        await offlineService.queueAction(
          OfflineActionType.create,
          '/api/test',
          {'test': 'data'},
        );
        
        final status = offlineService.getOfflineStatus();
        
        expect(status['isOnline'], isA<bool>());
        expect(status['connectivity'], isA<String>());
        expect(status['pendingActionsCount'], 1);
        expect(status['pendingActions'], isA<List>());
        
        final pendingActions = status['pendingActions'] as List;
        expect(pendingActions.length, 1);
        expect(pendingActions.first['type'], 'create');
        expect(pendingActions.first['endpoint'], '/api/test');
      });
    });

    tearDown(() {
      offlineService.dispose();
    });
  });
}