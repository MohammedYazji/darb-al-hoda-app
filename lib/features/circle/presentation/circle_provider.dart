// === State ===
import 'package:darb_al_hoda_app/core/models/circle_model.dart';
import 'package:darb_al_hoda_app/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CircleState {
  final bool isLoading;
  final CircleModel? circle;
  final String? error;

  const CircleState({this.isLoading = false, this.circle, this.error});

  CircleState copyWith({bool? isLoading, CircleModel? circle, String? error}) {
    return CircleState(
      isLoading: isLoading ?? this.isLoading,
      circle: circle ?? this.circle,
      error: error ?? this.error,
    );
  }

  // Helper
  bool get hasData => circle != null;
}

// === Notifier ===
// to handle circle actions with api
class CircleNotifier extends StateNotifier<CircleState> {
  final Dio _dio;

  CircleNotifier()
    : _dio = DioClient.instance,
      super(const CircleState(isLoading: true));

  // Fetch the circle data
  Future<void> fetchCircle(int circleId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _dio.get('/circles/$circleId');
      final circle = CircleModel.fromJson(response.data['data']);
      state = state.copyWith(circle: circle, isLoading: false);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'حدث خطأ';
      state = state.copyWith(isLoading: false, error: message);
    }
  }

  // Get circle for a sheikh
  Future<void> fetchMyCircle(int userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // fetch all circles
      final response = await _dio.get('/circles');
      final circles = response.data['data'] as List? ?? response.data as List;

      // Search circle if main or assistant sheikh
      final myCircle = circles.firstWhere(
        (c) =>
            c['main_sheikh']?['id'] == userId ||
            c['assistant_sheikh']?['id'] == userId,
        orElse: () => null,
      );

      if (myCircle == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'لا توجد حلقة مرتبطة بهذا الحساب',
        );
        return;
      }

      // Get the circle data with the student
      final circleId = myCircle['id'];
      final detailResponse = await _dio.get('/circles/$circleId');
      final circle = CircleModel.fromJson(
        detailResponse.data['data'] ?? detailResponse.data,
      );

      state = state.copyWith(isLoading: false, circle: circle);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'حدث خطأ';
      state = state.copyWith(isLoading: false, error: message);
    }
  }
}

// === Provider ===
final circleProvider = StateNotifierProvider<CircleNotifier, CircleState>((
  ref,
) {
  return CircleNotifier();
});
