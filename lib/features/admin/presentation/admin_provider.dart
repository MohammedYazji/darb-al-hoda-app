import 'package:darb_al_hoda_app/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// === Admin State - holds all dashboard data fetched from the API ===
class AdminState {
  final bool isLoading;
  final int studentsCount; // total active students in the center
  final int circlesCount; // total active study circles
  final int sheikhsCount; // total sheikhs (all roles combined)
  final int attendancePercentage; // this month's attendance rate (%)
  final int
  certificationCount; // certificates issued this week but not printed yet
  final List<Map<String, dynamic>> leaderboard; // top 5 students weekly
  final List<Map<String, dynamic>>
  recentActivity; // merged feed of recitations, nominations, new users
  final String? error;

  const AdminState({
    this.isLoading = false,
    this.studentsCount = 0,
    this.circlesCount = 0,
    this.sheikhsCount = 0,
    this.attendancePercentage = 0,
    this.certificationCount = 0,
    this.leaderboard = const [],
    this.recentActivity = const [],
    this.error,
  });

  // allows updating only the fields that changed without rebuilding the entire state
  AdminState copyWith({
    bool? isLoading,
    int? studentsCount,
    int? circlesCount,
    int? sheikhsCount,
    int? attendancePercentage,
    int? certificationCount,
    List<Map<String, dynamic>>? leaderboard,
    List<Map<String, dynamic>>? recentActivity,
    String? error,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      studentsCount: studentsCount ?? this.studentsCount,
      circlesCount: circlesCount ?? this.circlesCount,
      sheikhsCount: sheikhsCount ?? this.sheikhsCount,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      certificationCount: certificationCount ?? this.certificationCount,
      leaderboard: leaderboard ?? this.leaderboard,
      recentActivity: recentActivity ?? this.recentActivity,
      error: error,
    );
  }
}

// === AdminNotifier - fetches dashboard data from the backend ===
class AdminNotifier extends StateNotifier<AdminState> {
  final Dio _dio;

  AdminNotifier() : _dio = DioClient.instance, super(const AdminState());

  // GET /api/v1/admin/dashboard → parses each field into AdminState
  Future<void> fetchDashboard() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _dio.get('/admin/dashboard');
      final data = response.data as Map<String, dynamic>;

      state = state.copyWith(
        isLoading: false,
        studentsCount: data['students_count'] as int? ?? 0,
        circlesCount: data['circles_count'] as int? ?? 0,
        sheikhsCount: data['sheikhs_count'] as int? ?? 0,
        attendancePercentage: data['attendance_percentage'] as int? ?? 0,
        certificationCount: data['certification_count'] as int? ?? 0,
        leaderboard:
            (data['leaderboard'] as List?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [],
        recentActivity:
            (data['recent_activity'] as List?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [],
      );
    } on DioException catch (e) {
      // if the API is down show error message instead of crashing
      final message =
          e.response?.data['message'] ?? 'حدث خطأ في تحميل البيانات';
      state = state.copyWith(isLoading: false, error: message);
    }
  }
}

// === Riverpod provider - one instance shared across the admin screen ===
final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier();
});
