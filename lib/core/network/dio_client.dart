import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class DioClient {
  DioClient._();

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static Dio get instance {
    // set up the Dio config
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          // any format of data the flutter app can understand
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // === Request Interceptor ===
    // middleware to mutate the request, response if needed.
    dio.interceptors.add(
      InterceptorsWrapper(
        // instead of adding the token in each request i made the interceptors to add it automatically
        onRequest: (options, handler) async {
          // get the token from the storage
          final token = await _storage.read(key: AppConstants.tokenKey);
          // if it exist and the user is auth so send it with the request
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        // === Response Interceptor ===
        // do nothing when get the response from the app
        onResponse: (response, handler) {
          return handler.next(response);
        },

        // === Error Interceptor ===
        onError: (error, handler) async {
          // the token expired
          if (error.response?.statusCode == 401) {
            await _storage.delete(key: AppConstants.tokenKey);
            // TODO: navigate to login
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }
}
