import 'package:darb_al_hoda_app/core/constants/app_constants.dart';
import 'package:darb_al_hoda_app/core/models/user_model.dart';
import 'package:darb_al_hoda_app/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthState {
  final bool isLoading; // is login is happening now
  final UserModel? user; // current user - or null
  final String? error; // if any error happen i will stor it here
  final String? activeRole; // role of the current user

  const AuthState({
    this.isLoading = false, // default
    this.user,
    this.error,
    this.activeRole,
  });

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
    String? activeRole,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
      activeRole: activeRole ?? this.activeRole,
    );
  }

  // Helper methods
  bool get isAuthenticated => user != null;
  // so i need to display roles for the user after when it login based on if he have more than a role
  bool get needsRoleSelection =>
      user != null && user!.hasMultipleRoles && activeRole == null;
}

// All auth actions with the api
class AuthNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  AuthNotifier()
    : _storage = const FlutterSecureStorage(),
      _dio = DioClient.instance,
      super(const AuthState());

  // === Login ===
  Future<void> login(String email, String password) async {
    // 1. mutate the state to loading
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 2. send the request to the api
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      // 3. save the toke using flutter storage
      final token = response.data['token'];
      await _storage.write(key: AppConstants.tokenKey, value: token);

      // 4. use the model to change the json into object
      final user = UserModel.fromJson(response.data['user']);

      // 5. update the state
      state = state.copyWith(
        isLoading: false,
        user: user,
        activeRole: user.hasMultipleRoles ? null : user.roles.first,
      );
    } on DioException catch (e) {
      // Error from the API part
      final message = e.response?.data['message'] ?? 'حدث خظا, حاول مجدداً';
      state = state.copyWith(isLoading: false, error: message);
    }
  }

  // === Select Role ===
  // when select the destination after login
  void selectRole(String role) {
    state = state.copyWith(activeRole: role);
    _storage.write(key: AppConstants.activeRoleKey, value: role);
  }

  // === Logout ===
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
    // clear the storage
    await _storage.deleteAll();
    // return the state into the default values agin
    state = const AuthState();
  }

  // === Check if we have saved session ===
  // look for session when open the app
  // if we go out the app without logout
  Future<void> checkSession() async {
    // 0. get the token from the storage
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (token == null) return; // do nothing

    // 1. update the state while fetching the userdata
    state = state.copyWith(isLoading: true);

    try {
      // 2. fetch the user data from the API
      final response = await _dio.get('auth/me');
      final user = UserModel.fromJson(response.data);

      // 3. fetch the user role
      final activeRole = await _storage.read(key: AppConstants.activeRoleKey);

      // 4. mutate the state again
      state = state.copyWith(
        isLoading: false,
        user: user,
        activeRole:
            activeRole ?? (user.hasMultipleRoles ? null : user.roles.first),
      );
    } catch (_) {
      // if the token expired so logout
      await logout();
    }
  }
}

// === Provider ===
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
