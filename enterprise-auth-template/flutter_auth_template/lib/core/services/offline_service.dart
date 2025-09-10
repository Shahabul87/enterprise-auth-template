import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../error/app_exception.dart';

final offlineServiceProvider = Provider<OfflineService>((ref) {
  return OfflineService();
});

enum ConnectivityStatus {
  online,
  offline,
  limited,
}

enum OfflineActionType {
  create,
  update,
  delete,
  sync,
}

class PendingAction {
  final String id;
  final OfflineActionType type;
  final String endpoint;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;
  final Map<String, String>? headers;

  PendingAction({
    required this.id,
    required this.type,
    required this.endpoint,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
    this.headers,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'endpoint': endpoint,
      'data': data,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'retryCount': retryCount,
      'headers': headers,
    };
  }

  factory PendingAction.fromJson(Map<String, dynamic> json) {
    return PendingAction(
      id: json['id'],
      type: OfflineActionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OfflineActionType.sync,
      ),
      endpoint: json['endpoint'],
      data: Map<String, dynamic>.from(json['data']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      retryCount: json['retryCount'] ?? 0,
      headers: json['headers'] != null 
          ? Map<String, String>.from(json['headers'])
          : null,
    );
  }

  PendingAction copyWith({
    String? id,
    OfflineActionType? type,
    String? endpoint,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    int? retryCount,
    Map<String, String>? headers,
  }) {
    return PendingAction(
      id: id ?? this.id,
      type: type ?? this.type,
      endpoint: endpoint ?? this.endpoint,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      headers: headers ?? this.headers,
    );
  }
}

class OfflineService {
  static const String _pendingActionsKey = 'offline_pending_actions';
  static const String _cachedDataKey = 'offline_cached_data_';
  static const int _maxRetries = 3;
  static const Duration _syncTimeout = Duration(minutes: 5);
  
  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectivityStatus> _statusController = 
      StreamController<ConnectivityStatus>.broadcast();
  
  ConnectivityStatus _currentStatus = ConnectivityStatus.online;
  List<PendingAction> _pendingActions = [];
  Timer? _syncTimer;
  bool _isInitialized = false;

  Stream<ConnectivityStatus> get connectivityStream => _statusController.stream;
  ConnectivityStatus get currentStatus => _currentStatus;
  bool get isOnline => _currentStatus == ConnectivityStatus.online;
  bool get isOffline => _currentStatus == ConnectivityStatus.offline;
  List<PendingAction> get pendingActions => List.unmodifiable(_pendingActions);

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _loadPendingActions();
    await _checkConnectivity();
    _startConnectivityMonitoring();
    _startSyncTimer();
    
    _isInitialized = true;
  }

  void dispose() {
    _statusController.close();
    _syncTimer?.cancel();
  }

  void _startConnectivityMonitoring() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectivityStatus(result);
    });
  }

  void _startSyncTimer() {
    _syncTimer = Timer.periodic(_syncTimeout, (timer) {
      if (isOnline && _pendingActions.isNotEmpty) {
        _syncPendingActions();
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectivityStatus(result);
  }

  void _updateConnectivityStatus(ConnectivityResult result) {
    ConnectivityStatus newStatus;
    
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        newStatus = ConnectivityStatus.online;
        break;
      case ConnectivityResult.none:
        newStatus = ConnectivityStatus.offline;
        break;
      default:
        newStatus = ConnectivityStatus.limited;
    }

    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _statusController.add(_currentStatus);
      
      if (newStatus == ConnectivityStatus.online && _pendingActions.isNotEmpty) {
        _syncPendingActions();
      }
    }
  }

  Future<void> addPendingAction(PendingAction action) async {
    _pendingActions.add(action);
    await _savePendingActions();
    
    if (isOnline) {
      _syncPendingActions();
    }
  }

  Future<void> queueAction(
    OfflineActionType type,
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    final action = PendingAction(
      id: '${DateTime.now().millisecondsSinceEpoch}_${type.name}',
      type: type,
      endpoint: endpoint,
      data: data,
      timestamp: DateTime.now(),
      headers: headers,
    );
    
    await addPendingAction(action);
  }

  Future<void> _syncPendingActions() async {
    if (_pendingActions.isEmpty || !isOnline) return;
    
    final actionsToSync = List<PendingAction>.from(_pendingActions);
    final successfulActions = <PendingAction>[];
    final failedActions = <PendingAction>[];
    
    for (final action in actionsToSync) {
      try {
        await _syncAction(action);
        successfulActions.add(action);
      } catch (e) {
        final updatedAction = action.copyWith(retryCount: action.retryCount + 1);
        
        if (updatedAction.retryCount >= _maxRetries) {
          if (kDebugMode) {
            print('Action ${action.id} failed after ${_maxRetries} retries');
          }
          failedActions.add(action);
        } else {
          failedActions.add(updatedAction);
        }
      }
    }
    
    _pendingActions.removeWhere((action) => 
        successfulActions.contains(action) || 
        (failedActions.any((failed) => failed.id == action.id) && 
         failedActions.firstWhere((failed) => failed.id == action.id).retryCount >= _maxRetries));
    
    _pendingActions.addAll(failedActions.where((action) => action.retryCount < _maxRetries));
    
    await _savePendingActions();
  }

  Future<void> _syncAction(PendingAction action) async {
    // This would typically make HTTP requests to sync the action
    // For now, we'll simulate the sync operation
    await Future.delayed(const Duration(milliseconds: 100));
    
    switch (action.type) {
      case OfflineActionType.create:
        // Simulate POST request
        break;
      case OfflineActionType.update:
        // Simulate PUT/PATCH request
        break;
      case OfflineActionType.delete:
        // Simulate DELETE request
        break;
      case OfflineActionType.sync:
        // Simulate sync operation
        break;
    }
  }

  Future<void> _loadPendingActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final actionsJson = prefs.getStringList(_pendingActionsKey) ?? [];
      
      _pendingActions = actionsJson.map((actionStr) {
        final actionData = json.decode(actionStr);
        return PendingAction.fromJson(actionData);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading pending actions: $e');
      }
      _pendingActions = [];
    }
  }

  Future<void> _savePendingActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final actionsJson = _pendingActions.map((action) {
        return json.encode(action.toJson());
      }).toList();
      
      await prefs.setStringList(_pendingActionsKey, actionsJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving pending actions: $e');
      }
    }
  }

  Future<void> cacheData(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachedDataKey$key';
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await prefs.setString(cacheKey, json.encode(cacheData));
    } catch (e) {
      if (kDebugMode) {
        print('Error caching data for key $key: $e');
      }
    }
  }

  Future<Map<String, dynamic>?> getCachedData(
    String key, {
    Duration? maxAge,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachedDataKey$key';
      final cachedDataStr = prefs.getString(cacheKey);
      
      if (cachedDataStr == null) return null;
      
      final cacheData = json.decode(cachedDataStr);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(cacheData['timestamp']);
      
      if (maxAge != null && DateTime.now().difference(timestamp) > maxAge) {
        return null;
      }
      
      return Map<String, dynamic>.from(cacheData['data']);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cached data for key $key: $e');
      }
      return null;
    }
  }

  Future<void> clearCache({String? keyPattern}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      final keysToRemove = keys.where((key) {
        if (!key.startsWith(_cachedDataKey)) return false;
        if (keyPattern == null) return true;
        return key.contains(keyPattern);
      }).toList();
      
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cache: $e');
      }
    }
  }

  Future<void> clearPendingActions() async {
    _pendingActions.clear();
    await _savePendingActions();
  }

  Future<bool> hasPendingActionsForEndpoint(String endpoint) async {
    return _pendingActions.any((action) => action.endpoint == endpoint);
  }

  Future<List<PendingAction>> getPendingActionsForEndpoint(String endpoint) async {
    return _pendingActions.where((action) => action.endpoint == endpoint).toList();
  }

  Future<void> removePendingAction(String actionId) async {
    _pendingActions.removeWhere((action) => action.id == actionId);
    await _savePendingActions();
  }

  Future<void> forceSyncNow() async {
    if (!isOnline) {
      throw AppException.connectivity(
        message: 'Cannot sync while offline',
        type: 'no_connection',
      );
    }
    
    await _syncPendingActions();
  }

  Map<String, dynamic> getOfflineStatus() {
    return {
      'isOnline': isOnline,
      'connectivity': _currentStatus.name,
      'pendingActionsCount': _pendingActions.length,
      'lastSyncAttempt': _syncTimer != null ? DateTime.now().toIso8601String() : null,
      'pendingActions': _pendingActions.map((action) => {
        'id': action.id,
        'type': action.type.name,
        'endpoint': action.endpoint,
        'timestamp': action.timestamp.toIso8601String(),
        'retryCount': action.retryCount,
      }).toList(),
    };
  }
}