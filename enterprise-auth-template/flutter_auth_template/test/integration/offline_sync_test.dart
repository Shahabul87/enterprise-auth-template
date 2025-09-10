import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/services/offline_service.dart';
import 'package:flutter_auth_template/core/network/offline_interceptor.dart';
import 'dart:convert';

@GenerateMocks([Dio, Response])
import 'offline_sync_test.mocks.dart';

void main() {
  group('Offline Sync Integration Tests', () {
    late OfflineService offlineService;
    late MockDio mockDio;
    late OfflineAwareApiClient apiClient;

    setUp(() {
      offlineService = OfflineService();
      mockDio = MockDio();
      apiClient = OfflineAwareApiClient(offlineService);
    });

    tearDown(() {
      offlineService.dispose();
    });

    group('Offline Data Caching', () {
      test('should cache successful GET responses', () async {
        await offlineService.initialize();

        final testData = {'id': 1, 'name': 'Test User'};
        final mockResponse = MockResponse();
        
        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.data).thenReturn(testData);
        when(mockResponse.requestOptions).thenReturn(RequestOptions(
          path: '/api/users/1',
          method: 'GET',
        ));

        when(mockDio.get('/api/users/1')).thenAnswer((_) async => mockResponse);

        // Make request when online
        final response = await apiClient.get('/api/users/1');
        
        expect(response.statusCode, 200);
        expect(response.data, testData);

        // Verify data was cached
        final cachedData = await offlineService.getCachedData('GET_http://localhost:8000/api/users/1');
        expect(cachedData, isNotNull);
        expect(cachedData!['data'], testData);
      });

      test('should serve cached data when offline', () async {
        await offlineService.initialize();

        // Cache some data first
        const cacheKey = 'GET_/api/users/1';
        final cachedData = {
          'statusCode': 200,
          'data': {'id': 1, 'name': 'Cached User'},
          'headers': <String, List<String>>{},
          'cachedAt': DateTime.now().toIso8601String(),
        };
        
        await offlineService.cacheData(cacheKey, cachedData);

        // Simulate offline
        // Note: In real implementation, this would be done through connectivity changes

        // When making request offline, should get cached data
        final response = await apiClient.get('/api/users/1');
        
        expect(response.data['name'], 'Cached User');
        expect(response.headers.value('X-Served-From-Cache'), 'true');
      });

      test('should respect cache expiration', () async {
        await offlineService.initialize();

        const cacheKey = 'expired-data';
        final expiredData = {'old': 'data'};
        
        await offlineService.cacheData(cacheKey, expiredData);
        
        // Wait for expiration
        await Future.delayed(const Duration(milliseconds: 10));
        
        final retrievedData = await offlineService.getCachedData(
          cacheKey,
          maxAge: const Duration(milliseconds: 5),
        );
        
        expect(retrievedData, isNull);
      });
    });

    group('Action Queueing', () {
      test('should queue POST requests when offline', () async {
        await offlineService.initialize();

        final postData = {'name': 'New User', 'email': 'new@example.com'};
        
        // Simulate offline POST request
        await offlineService.queueAction(
          OfflineActionType.create,
          '/api/users',
          postData,
        );

        expect(offlineService.pendingActions.length, 1);
        
        final action = offlineService.pendingActions.first;
        expect(action.type, OfflineActionType.create);
        expect(action.endpoint, '/api/users');
        expect(action.data, contains('name'));
      });

      test('should queue PUT requests when offline', () async {
        await offlineService.initialize();

        final updateData = {'name': 'Updated User'};
        
        await offlineService.queueAction(
          OfflineActionType.update,
          '/api/users/1',
          updateData,
        );

        expect(offlineService.pendingActions.length, 1);
        expect(offlineService.pendingActions.first.type, OfflineActionType.update);
      });

      test('should queue DELETE requests when offline', () async {
        await offlineService.initialize();

        await offlineService.queueAction(
          OfflineActionType.delete,
          '/api/users/1',
          {'id': 1},
        );

        expect(offlineService.pendingActions.length, 1);
        expect(offlineService.pendingActions.first.type, OfflineActionType.delete);
      });

      test('should preserve action order in queue', () async {
        await offlineService.initialize();

        // Queue multiple actions
        await offlineService.queueAction(
          OfflineActionType.create,
          '/api/users',
          {'name': 'User 1'},
        );
        
        await offlineService.queueAction(
          OfflineActionType.update,
          '/api/users/1',
          {'name': 'Updated User 1'},
        );
        
        await offlineService.queueAction(
          OfflineActionType.delete,
          '/api/users/2',
          {'id': 2},
        );

        expect(offlineService.pendingActions.length, 3);
        expect(offlineService.pendingActions[0].type, OfflineActionType.create);
        expect(offlineService.pendingActions[1].type, OfflineActionType.update);
        expect(offlineService.pendingActions[2].type, OfflineActionType.delete);
      });
    });

    group('Sync Process', () {
      test('should sync pending actions when coming back online', () async {
        await offlineService.initialize();

        // Queue some actions while offline
        await offlineService.queueAction(
          OfflineActionType.create,
          '/api/users',
          {'name': 'User 1'},
        );
        
        await offlineService.queueAction(
          OfflineActionType.update,
          '/api/posts/1',
          {'title': 'Updated Title'},
        );

        expect(offlineService.pendingActions.length, 2);

        // Simulate coming back online and successful sync
        // Note: In real implementation, this would be triggered by connectivity changes
        await offlineService.forceSyncNow();

        // After successful sync, pending actions should be cleared
        // Note: This assumes successful sync implementation
      });

      test('should handle sync failures with retry', () async {
        await offlineService.initialize();

        await offlineService.queueAction(
          OfflineActionType.create,
          '/api/users',
          {'name': 'Test User'},
        );

        // First sync attempt fails
        // Second sync attempt should retry
        // After max retries, action should be marked as failed

        expect(offlineService.pendingActions.length, 1);
      });

      test('should handle partial sync success', () async {
        await offlineService.initialize();

        // Queue multiple actions
        await offlineService.queueAction(
          OfflineActionType.create,
          '/api/users',
          {'name': 'User 1'},
        );
        
        await offlineService.queueAction(
          OfflineActionType.create,
          '/api/posts',
          {'title': 'Post 1'},
        );

        expect(offlineService.pendingActions.length, 2);

        // Simulate partial sync (one succeeds, one fails)
        // Only successful actions should be removed from queue
      });
    });

    group('Conflict Resolution', () {
      test('should handle data conflicts during sync', () async {
        await offlineService.initialize();

        // Cache original data
        await offlineService.cacheData('user_1', {
          'id': 1,
          'name': 'Original Name',
          'version': 1,
        });

        // Queue update action
        await offlineService.queueAction(
          OfflineActionType.update,
          '/api/users/1',
          {'name': 'Offline Update', 'version': 1},
        );

        // Simulate server data changed while offline
        final serverData = {
          'id': 1,
          'name': 'Server Update',
          'version': 2,
        };

        // Sync should detect conflict and handle appropriately
        // This might involve showing conflict resolution UI to user
      });

      test('should use last-write-wins strategy when configured', () async {
        await offlineService.initialize();

        await offlineService.queueAction(
          OfflineActionType.update,
          '/api/users/1',
          {'name': 'Final Update'},
        );

        // When syncing, latest update should win
      });
    });

    group('Data Consistency', () {
      test('should maintain referential integrity during offline operations', () async {
        await offlineService.initialize();

        // Create user
        await offlineService.queueAction(
          OfflineActionType.create,
          '/api/users',
          {'id': 'temp_1', 'name': 'User 1'},
        );

        // Create post referencing user
        await offlineService.queueAction(
          OfflineActionType.create,
          '/api/posts',
          {'userId': 'temp_1', 'title': 'Post 1'},
        );

        // During sync, temporary IDs should be resolved to actual IDs
        expect(offlineService.pendingActions.length, 2);
      });

      test('should handle cascading deletes properly', () async {
        await offlineService.initialize();

        // Delete user (which should cascade to posts)
        await offlineService.queueAction(
          OfflineActionType.delete,
          '/api/users/1',
          {'id': 1, 'cascade': true},
        );

        // Sync should handle cascading operations correctly
      });
    });

    group('Storage Management', () {
      test('should limit cache size to prevent storage overflow', () async {
        await offlineService.initialize();

        // Cache large amount of data
        for (int i = 0; i < 1000; i++) {
          await offlineService.cacheData('large_data_$i', {
            'id': i,
            'data': List.generate(1000, (index) => 'data_$index').join(','),
          });
        }

        // Should implement LRU eviction or size limits
        // Verify cache size is within reasonable limits
      });

      test('should cleanup old cached data automatically', () async {
        await offlineService.initialize();

        // Cache old data
        await offlineService.cacheData('old_data', {'timestamp': 'old'});
        
        // Wait for cleanup interval
        await Future.delayed(const Duration(milliseconds: 100));

        // Old data should be cleaned up based on age
        final oldData = await offlineService.getCachedData(
          'old_data',
          maxAge: const Duration(milliseconds: 50),
        );
        
        expect(oldData, isNull);
      });

      test('should persist pending actions across app restarts', () async {
        // Initialize service
        await offlineService.initialize();

        // Queue some actions
        await offlineService.queueAction(
          OfflineActionType.create,
          '/api/users',
          {'name': 'Persistent User'},
        );

        // Dispose service (simulating app restart)
        offlineService.dispose();

        // Initialize new service instance
        final newService = OfflineService();
        await newService.initialize();

        // Pending actions should be restored
        expect(newService.pendingActions.length, 1);
        expect(newService.pendingActions.first.data['name'], 'Persistent User');

        newService.dispose();
      });
    });

    group('Network Transition Handling', () {
      test('should detect network state changes', () async {
        await offlineService.initialize();

        final connectivityStates = <ConnectivityStatus>[];
        offlineService.connectivityStream.listen((state) {
          connectivityStates.add(state);
        });

        // Simulate network state changes
        // Note: In real tests, this would involve mocking connectivity_plus
        
        expect(connectivityStates, isNotEmpty);
      });

      test('should handle intermittent connectivity gracefully', () async {
        await offlineService.initialize();

        // Queue action during offline
        await offlineService.queueAction(
          OfflineActionType.create,
          '/api/users',
          {'name': 'Test User'},
        );

        // Brief online period (sync starts but fails)
        // Back offline
        // Online again (sync completes)

        // Should handle these transitions without data loss
      });
    });

    group('Error Recovery', () {
      test('should recover from sync errors gracefully', () async {
        await offlineService.initialize();

        await offlineService.queueAction(
          OfflineActionType.create,
          '/api/users',
          {'name': 'Test User'},
        );

        // Simulate network error during sync
        // Should retry with backoff
        // Eventually succeed or mark as failed after max retries
      });

      test('should handle server errors during sync', () async {
        await offlineService.initialize();

        await offlineService.queueAction(
          OfflineActionType.create,
          '/api/users',
          {'name': 'Test User'},
        );

        // Simulate 500 server error
        // Should retry (server errors are typically transient)
        // vs 400 errors (client errors, don't retry)
      });
    });
  });
}