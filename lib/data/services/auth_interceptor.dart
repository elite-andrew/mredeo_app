import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:redeo_app/config/app_config.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthInterceptor(this._dio, this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add access token to requests (except auth endpoints)
    if (!_isAuthEndpoint(options.path)) {
      final accessToken = await _storage.read(key: AppConfig.accessTokenKey);
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !_isAuthEndpoint(err.requestOptions.path)) {
      // Try to refresh token
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry the original request
        try {
          final clonedRequest = await _dio.request(
            err.requestOptions.path,
            options: Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
            ),
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
          );
          handler.resolve(clonedRequest);
          return;
        } catch (e) {
          developer.log('Retry request failed: $e', name: 'AuthInterceptor');
        }
      } else {
        // Refresh failed, logout user
        await _clearTokens();
      }
    }
    handler.next(err);
  }

  bool _isAuthEndpoint(String path) {
    final authPaths = [
      ApiEndpoints.login,
      ApiEndpoints.signup,
      ApiEndpoints.verifyOTP,
      ApiEndpoints.forgotPassword,
      ApiEndpoints.resetPassword,
      ApiEndpoints.refreshToken,
    ];
    return authPaths.any((authPath) => path.contains(authPath));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: AppConfig.refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _storage.write(
          key: AppConfig.accessTokenKey,
          value: data['access_token'],
        );
        await _storage.write(
          key: AppConfig.refreshTokenKey,
          value: data['refresh_token'],
        );
        return true;
      }
    } catch (e) {
      developer.log('Token refresh failed: $e', name: 'AuthInterceptor');
    }
    return false;
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: AppConfig.accessTokenKey);
    await _storage.delete(key: AppConfig.refreshTokenKey);
    await _storage.delete(key: AppConfig.userDataKey);
    await _storage.delete(key: AppConfig.isLoggedInKey);
  }
}
