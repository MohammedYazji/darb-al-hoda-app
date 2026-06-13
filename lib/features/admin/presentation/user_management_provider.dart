import 'package:darb_al_hoda_app/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// === ManagedUser model ===
// maps the user data from the api into a Dart object
class ManagedUser {
  final int id;
  final String name;
  final String uniqueNumber;
  final String phone;
  final List<String> roles;
  final Map<String, dynamic>? circle;
  final Map<String, dynamic>? course;

  const ManagedUser({
    required this.id,
    required this.name,
    required this.uniqueNumber,
    required this.phone,
    required this.roles,
    this.circle,
    this.course,
  });

  // parse the json from the api into a managed user object
  factory ManagedUser.fromJson(Map<String, dynamic> json) {
    return ManagedUser(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      uniqueNumber: json['unique_number'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      roles: (json['roles'] as List?)?.map((e) => e as String).toList() ?? [],
      circle: json['circle'] as Map<String, dynamic>?,
      course: json['course'] as Map<String, dynamic>?,
    );
  }
}

// === State ===
// holds the current state of the user management page
class UserManagementState {
  final bool isLoading;
  final bool isSaving;
  final List<ManagedUser> users;
  final List<Map<String, dynamic>> circles;
  final List<Map<String, dynamic>> courses;
  final String? error;
  final String? successMessage;

  const UserManagementState({
    this.isLoading = false,
    this.isSaving = false,
    this.users = const [],
    this.circles = const [],
    this.courses = const [],
    this.error,
    this.successMessage,
  });

  // update some properties to make ui rerender with the new changes
  UserManagementState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<ManagedUser>? users,
    List<Map<String, dynamic>>? circles,
    List<Map<String, dynamic>>? courses,
    String? error,
    String? successMessage,
  }) {
    return UserManagementState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      users: users ?? this.users,
      circles: circles ?? this.circles,
      courses: courses ?? this.courses,
      error: error,
      successMessage: successMessage,
    );
  }
}

// === Notifier ===
// handles all the api calls for user management
class UserManagementNotifier extends StateNotifier<UserManagementState> {
  final Dio _dio;

  UserManagementNotifier()
    : _dio = DioClient.instance,
      super(const UserManagementState());

  // fetch all users from the api
  Future<void> fetchUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get('/admin/users');
      final data = response.data as List;
      state = state.copyWith(
        isLoading: false,
        users: data
            .map((e) => ManagedUser.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? 'حدث خطأ في تحميل المستخدمين';
      state = state.copyWith(isLoading: false, error: message);
    }
  }

  // create a new user will returns the generated password and unique number
  Future<Map<String, String>?> createUser({
    required String name,
    required String phone,
    required List<String> roles,
    int? circleId,
    int? sheikhCircleId,
    int? courseId,
    String? fatherPhone,
  }) async {
    state = state.copyWith(isSaving: true, error: null, successMessage: null);
    try {
      final body = <String, dynamic>{
        'name': name,
        'phone': phone.isEmpty ? null : phone,
        'roles': roles,
      };
      if (circleId != null) body['circle_id'] = circleId;
      if (sheikhCircleId != null) body['sheikh_circle_id'] = sheikhCircleId;
      if (courseId != null) body['course_id'] = courseId;
      if (fatherPhone != null && fatherPhone.isNotEmpty)
        body['father_phone'] = fatherPhone;

      final response = await _dio.post('/admin/users', data: body);
      final password = response.data['password'] as String? ?? '';
      final uniqueNumber =
          response.data['user']?['unique_number'] as String? ?? '';
      state = state.copyWith(
        isSaving: false,
        successMessage: 'تم إنشاء المستخدم بنجاح',
      );
      await fetchUsers();
      return {'password': password, 'uniqueNumber': uniqueNumber};
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? 'حدث خطأ في إنشاء المستخدم';
      state = state.copyWith(isSaving: false, error: message);
      return null;
    }
  }

  // update the roles and settings of an existing user
  Future<bool> updateUserRoles({
    required int userId,
    required List<String> roles,
    int? circleId,
    int? sheikhCircleId,
    int? courseId,
    String? fatherPhone,
  }) async {
    state = state.copyWith(isSaving: true, error: null, successMessage: null);
    try {
      final body = <String, dynamic>{'roles': roles};
      if (circleId != null) body['circle_id'] = circleId;
      if (sheikhCircleId != null) body['sheikh_circle_id'] = sheikhCircleId;
      if (courseId != null) body['course_id'] = courseId;
      if (fatherPhone != null) body['father_phone'] = fatherPhone;

      await _dio.put('/admin/users/$userId/roles', data: body);
      state = state.copyWith(
        isSaving: false,
        successMessage: 'تم تحديث الأدوار بنجاح',
      );
      await fetchUsers();
      return true;
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'حدث خطأ في تحديث الأدوار';
      state = state.copyWith(isSaving: false, error: message);
      return false;
    }
  }

  // load the circles and courses lists for the dropdowns
  Future<void> fetchCirclesAndCourses() async {
    try {
      final results = await Future.wait([
        _dio.get('/circles'),
        _dio.get('/tajweed-courses'),
      ]);
      // handle both wrapped and unwrapped api responses
      final rawCircles = results[0].data;
      final circlesList = rawCircles is List
          ? rawCircles
          : (rawCircles['data'] as List? ?? []);
      final circles = circlesList
          .map((e) => {'id': e['id'] as int, 'name': e['name'] as String})
          .toList();
      final rawCourses = results[1].data;
      final coursesList = rawCourses is List
          ? rawCourses
          : (rawCourses['data'] as List? ?? []);
      final courses = coursesList
          .map((e) => {'id': e['id'] as int, 'name': e['name'] as String})
          .toList();
      state = state.copyWith(circles: circles, courses: courses);
    } catch (e) {
      state = state.copyWith(error: 'فشل تحميل الحلقات: $e');
    }
  }

  // clear the success and error messages
  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

// === Provider ===
final userManagementProvider =
    StateNotifierProvider<UserManagementNotifier, UserManagementState>((ref) {
      return UserManagementNotifier();
    });
