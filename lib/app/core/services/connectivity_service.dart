import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Global connectivity monitoring service
///
/// Provides reactive connectivity state and auto-refresh triggers.
/// Register as a GetxService at app startup.
class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Current online status (reactive)
  final RxBool isOnline = true.obs;

  /// Last time the device was confirmed online
  DateTime lastOnline = DateTime.now();

  /// Callbacks to execute when connectivity is restored
  final List<VoidCallback> _onReconnectCallbacks = [];
  Timer? _reconnectDebounce;

  /// Initialize monitoring
  Future<ConnectivityService> init() async {
    // Check initial state
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
    return this;
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final wasOffline = !isOnline.value;
    final nowOnline = results.any((r) => r != ConnectivityResult.none);

    isOnline.value = nowOnline;

    if (nowOnline) {
      lastOnline = DateTime.now();
      // Trigger reconnect callbacks if we were offline (debounced to avoid flapping)
      if (wasOffline) {
        _reconnectDebounce?.cancel();
        _reconnectDebounce = Timer(const Duration(seconds: 3), () {
          if (isOnline.value) {
            debugPrint('ConnectivityService: Back online - triggering refresh');
            for (final callback in _onReconnectCallbacks) {
              callback();
            }
          }
        });
      }
    } else {
      _reconnectDebounce?.cancel();
      debugPrint('ConnectivityService: Device is offline');
    }
  }

  /// Register a callback to run when connectivity is restored
  void onReconnect(VoidCallback callback) {
    _onReconnectCallbacks.add(callback);
  }

  /// Remove a reconnect callback
  void removeReconnectCallback(VoidCallback callback) {
    _onReconnectCallbacks.remove(callback);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _reconnectDebounce?.cancel();
    _onReconnectCallbacks.clear();
    super.onClose();
  }
}
