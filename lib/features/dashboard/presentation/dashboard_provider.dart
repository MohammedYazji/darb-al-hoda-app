// === Dashboard State ===
import 'package:darb_al_hoda_app/core/models/dashboard_model.dart';
import 'package:darb_al_hoda_app/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardState {
  final bool isLoading;
  final DashboardModel? data; // Dashborad data
  final String? error;

  const DashboardState({this.isLoading = false, this.data, this.error});

  // this will call when i write state.copyWith after a while
  DashboardState copyWith({
    bool? isLoading,
    DashboardModel? data,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  // === Helper Methods ===
  bool get hasData => data != null;
}

// === Dashboard Notifier ===
// to deal with the api
class DashboardNotifier extends StateNotifier<DashboardState> {
  final Dio _dio;

  DashboardNotifier()
    : _dio = DioClient.instance,
      super(const DashboardState());

  // === Fetch the dashboard data from the API ===
  Future<void> fetchDashboard() async {
    // 1. update the state of loading and clear errors if we have
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 2. make the request and get data as object not json
      final response = await _dio.get('/dashboard');
      final data = DashboardModel.fromJson(response.data);

      // 3. update the state with the new data
      state = state.copyWith(isLoading: false, data: data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'حدث خطأ';
      state = state.copyWith(isLoading: false, error: message);
    }
  }
}

// === Provider ===
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      return DashboardNotifier();
    });
