import 'package:connectivity_plus/connectivity_plus.dart';

// === Connectivity Service ===
// detects whether the device currently has a network connection
// Note: "connected" means a network interface is active - it doesnt
// ensure the API is reachable (e.g. connected to Wifi but no internet)
class ConnectivityService {
  ConnectivityService._();

  static final Connectivity _connectivity = Connectivity();

  // === Online Stream ===
  // emits true when online, false when offline - i think would be useful for real-time UI updates
  static Stream<bool> get onlineStream =>
      _connectivity.onConnectivityChanged.map((results) => _isOnline(results));

  // === Quick Check ===
  // one-shot check of current connectivity state
  static Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _isOnline(results);
  }

  // helper to check if any of the results indicate a valid connection
  static bool _isOnline(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );
  }
}
