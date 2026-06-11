import 'dart:convert';
import 'package:darb_al_hoda_app/core/constants/app_constants.dart';
import 'package:darb_al_hoda_app/core/models/user_model.dart';
import 'package:darb_al_hoda_app/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// === Auth State ===
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

// === Auth Notifier ===
// handles all auth actions with the api and local session recovery
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

      // 3. save the token using flutter storage
      final token = response.data['token'];
      await _storage.write(key: AppConstants.tokenKey, value: token);

      // 4. use the model to change the json into object
      final userJson = response.data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userJson);

      // 5. cache user JSON locally for offline startup
      await _storage.write(
        key: AppConstants.userKey,
        value: jsonEncode(userJson),
      );

      // 6. update the state
      state = state.copyWith(
        isLoading: false,
        user: user,
        activeRole: user.hasMultipleRoles ? null : user.roles.first,
      );
    } on DioException catch (e) {
      // Error from the API part
      final message = e.response?.data['message'] ?? 'حدث خطأ, حاول مجدداً';
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
    // clear all storage including cached user data
    await _storage.deleteAll();
    // return the state into the default values again
    state = const AuthState();
  }

  // === Check Session ===
  // called when opening the app — restores session without login
  Future<void> checkSession() async {
    // 0. check if we have a stored token
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (token == null) return; // no session at all

    // 1. show loading while resolving session
    state = state.copyWith(isLoading: true);

    try {
      // 2. fetch fresh user data from the API (requires internet)
      final response = await _dio.get('/auth/me');
      final userJson = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(userJson);

      // 3. update local user cache with fresh data
      await _storage.write(
        key: AppConstants.userKey,
        value: jsonEncode(userJson),
      );

      // 4. fetch the stored active role
      final activeRole = await _storage.read(key: AppConstants.activeRoleKey);

      // 5. restore full session state
      state = state.copyWith(
        isLoading: false,
        user: user,
        activeRole:
            activeRole ?? (user.hasMultipleRoles ? null : user.roles.first),
      );
    } catch (_) {
      // API call failed — offline or token expired.
      // Try to restore from locally cached user JSON first.
      final cachedJson = await _storage.read(key: AppConstants.userKey);

      if (cachedJson != null) {
        try {
          final userJson = jsonDecode(cachedJson) as Map<String, dynamic>;
          final user = UserModel.fromJson(userJson);
          final activeRole = await _storage.read(
            key: AppConstants.activeRoleKey,
          );

          // Offline but valid cache → restore full session
          state = state.copyWith(
            isLoading: false,
            user: user,
            activeRole:
                activeRole ?? (user.hasMultipleRoles ? null : user.roles.first),
          );
          return;
        } catch (_) {
          // Cached data is corrupt — fall through to logout
        }
      }

      // No cache or corrupt → token is invalid, log out cleanly
      await logout();
    }
  }
}

// === Provider ===
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
