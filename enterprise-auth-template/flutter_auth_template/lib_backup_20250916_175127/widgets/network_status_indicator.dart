import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network status indicator widget
class NetworkStatusIndicator extends StatefulWidget {
  final Widget child;
  final bool showBanner;
  final Duration checkInterval;
  final Function(bool isConnected)? onStatusChanged;

  const NetworkStatusIndicator({
    Key? key,
    required this.child,
    this.showBanner = true,
    this.checkInterval = const Duration(seconds: 5),
    this.onStatusChanged,
  }) : super(key: key);

  @override
  State<NetworkStatusIndicator> createState() => _NetworkStatusIndicatorState();
}

class _NetworkStatusIndicatorState extends State<NetworkStatusIndicator>
    with SingleTickerProviderStateMixin {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _isConnected = true;
  bool _wasDisconnected = false;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.wifi];

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Could not check connectivity status: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      _connectionStatus = result;
      final wasConnected = _isConnected;
      _isConnected =
          !result.contains(ConnectivityResult.none) && result.isNotEmpty;

      if (!_isConnected) {
        _wasDisconnected = true;
        _animationController.forward();
      } else if (wasConnected != _isConnected && _wasDisconnected) {
        // Show reconnected message briefly
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _animationController.reverse();
            setState(() {
              _wasDisconnected = false;
            });
          }
        });
      } else {
        _animationController.reverse();
      }

      widget.onStatusChanged?.call(_isConnected);
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showBanner) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        if (!_isConnected || _wasDisconnected)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(_animation),
              child: NetworkStatusBanner(
                isConnected: _isConnected,
                connectionType: _connectionStatus,
              ),
            ),
          ),
      ],
    );
  }
}

/// Network status banner
class NetworkStatusBanner extends StatelessWidget {
  final bool isConnected;
  final List<ConnectivityResult> connectionType;

  const NetworkStatusBanner({
    Key? key,
    required this.isConnected,
    required this.connectionType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      child: Container(
        color: isConnected ? Colors.green : Colors.red,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          bottom: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isConnected
                  ? 'Connected${_getConnectionTypeText(connectionType)}'
                  : 'No Internet Connection',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getConnectionTypeText(List<ConnectivityResult> types) {
    if (types.isEmpty) return '';

    // Show the primary connection type
    final primaryType = types.first;
    switch (primaryType) {
      case ConnectivityResult.wifi:
        return ' (WiFi)';
      case ConnectivityResult.mobile:
        return ' (Mobile)';
      case ConnectivityResult.ethernet:
        return ' (Ethernet)';
      default:
        return '';
    }
  }
}

/// Floating network status indicator
class FloatingNetworkIndicator extends StatefulWidget {
  final Widget child;
  final Alignment alignment;
  final EdgeInsetsGeometry padding;
  final bool showOnlyWhenOffline;

  const FloatingNetworkIndicator({
    Key? key,
    required this.child,
    this.alignment = Alignment.bottomCenter,
    this.padding = const EdgeInsets.all(16),
    this.showOnlyWhenOffline = true,
  }) : super(key: key);

  @override
  State<FloatingNetworkIndicator> createState() =>
      _FloatingNetworkIndicatorState();
}

class _FloatingNetworkIndicatorState extends State<FloatingNetworkIndicator>
    with SingleTickerProviderStateMixin {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late AnimationController _animationController;

  bool _isConnected = true;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.wifi];

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Could not check connectivity status: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      _connectionStatus = result;
      _isConnected =
          !result.contains(ConnectivityResult.none) && result.isNotEmpty;

      if (!_isConnected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shouldShow = widget.showOnlyWhenOffline ? !_isConnected : true;

    return Stack(
      children: [
        widget.child,
        if (shouldShow)
          Positioned.fill(
            child: Align(
              alignment: widget.alignment,
              child: Padding(
                padding: widget.padding,
                child: ScaleTransition(
                  scale: _animationController,
                  child: NetworkStatusChip(
                    isConnected: _isConnected,
                    connectionType: _connectionStatus,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Network status chip
class NetworkStatusChip extends StatelessWidget {
  final bool isConnected;
  final List<ConnectivityResult> connectionType;

  const NetworkStatusChip({
    Key? key,
    required this.isConnected,
    required this.connectionType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isConnected
            ? Colors.green.withValues(alpha: 0.9)
            : Colors.red.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConnected ? Icons.check_circle : Icons.error,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            isConnected ? 'Online' : 'Offline',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Network aware builder
class NetworkAwareBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isConnected) builder;
  final Widget? offlineWidget;

  const NetworkAwareBuilder({
    Key? key,
    required this.builder,
    this.offlineWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final isConnected =
            snapshot.hasData &&
            snapshot.data!.isNotEmpty &&
            !snapshot.data!.contains(ConnectivityResult.none);

        if (!isConnected && offlineWidget != null) {
          return offlineWidget!;
        }

        return builder(context, isConnected);
      },
    );
  }
}

/// Network status service (singleton)
class NetworkStatusService {
  static final NetworkStatusService _instance =
      NetworkStatusService._internal();
  factory NetworkStatusService() => _instance;
  NetworkStatusService._internal();

  final _connectivity = Connectivity();
  final _statusController = StreamController<bool>.broadcast();

  Stream<bool> get statusStream => _statusController.stream;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  void init() {
    _connectivity.onConnectivityChanged.listen((result) {
      _isConnected =
          !result.contains(ConnectivityResult.none) && result.isNotEmpty;
      _statusController.add(_isConnected);
    });

    checkConnectivity();
  }

  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected =
        !result.contains(ConnectivityResult.none) && result.isNotEmpty;
    _statusController.add(_isConnected);
    return _isConnected;
  }

  void dispose() {
    _statusController.close();
  }
}
