import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/offline_service.dart';

final offlineStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final offlineService = ref.watch(offlineServiceProvider);
  return offlineService.connectivityStream;
});

final isOnlineProvider = Provider<bool>((ref) {
  final status = ref.watch(offlineStatusProvider);
  return status.when(
    data: (status) => status == ConnectivityStatus.online,
    loading: () => true, // Assume online while loading
    error: (_, __) => false,
  );
});

final pendingActionsCountProvider = StateNotifierProvider<PendingActionsNotifier, int>((ref) {
  return PendingActionsNotifier(ref.read(offlineServiceProvider));
});

class PendingActionsNotifier extends StateNotifier<int> {
  final OfflineService _offlineService;

  PendingActionsNotifier(this._offlineService) : super(0) {
    _init();
  }

  void _init() {
    _updateCount();
    
    // Listen to connectivity changes to update count
    _offlineService.connectivityStream.listen((_) {
      _updateCount();
    });
  }

  void _updateCount() {
    state = _offlineService.pendingActions.length;
  }

  Future<void> refresh() async {
    _updateCount();
  }

  Future<void> clearAll() async {
    await _offlineService.clearPendingActions();
    state = 0;
  }

  Future<void> syncNow() async {
    await _offlineService.forceSyncNow();
    _updateCount();
  }
}

final offlineDataCacheNotifier = StateNotifierProvider.family<
    OfflineDataCacheNotifier, 
    AsyncValue<Map<String, dynamic>?>, 
    String>((ref, cacheKey) {
  return OfflineDataCacheNotifier(
    ref.read(offlineServiceProvider), 
    cacheKey,
  );
});

class OfflineDataCacheNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final OfflineService _offlineService;
  final String _cacheKey;

  OfflineDataCacheNotifier(this._offlineService, this._cacheKey) 
      : super(const AsyncValue.loading()) {
    _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    try {
      final data = await _offlineService.getCachedData(
        _cacheKey,
        maxAge: const Duration(hours: 24),
      );
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateCache(Map<String, dynamic> data) async {
    try {
      await _offlineService.cacheData(_cacheKey, data);
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> clearCache() async {
    try {
      await _offlineService.clearCache(keyPattern: _cacheKey);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadCachedData();
  }
}