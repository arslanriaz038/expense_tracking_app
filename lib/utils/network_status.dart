import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkStatus {
  NetworkStatus._();

  static final _connectivity = Connectivity();

  static Future<bool> get isOnline async {
    try {
      final results = await _connectivity
          .checkConnectivity()
          .timeout(const Duration(seconds: 2));
      return _hasConnection(results);
    } catch (_) {
      return false;
    }
  }

  static Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_hasConnection);
  }

  static bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
