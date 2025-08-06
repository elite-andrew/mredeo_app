import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:redeo_app/config/app_config.dart';
import 'package:redeo_app/data/services/auth_interceptor.dart';
import 'package:redeo_app/data/services/retry_interceptor.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.apiTimeout,
      receiveTimeout: AppConfig.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors
    _dio.interceptors.add(AuthInterceptor(_dio, _storage));
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: AppConfig.enableLogging,
        responseBody: AppConfig.enableLogging,
        logPrint: (obj) => developer.log(obj.toString(), name: 'ApiService'),
      ),
    );
    _dio.interceptors.add(RetryInterceptor());
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    await _checkConnectivity();
    return await _dio.get(path, queryParameters: queryParameters);
  }

  // POST request
  Future<Response> post(String path, {dynamic data}) async {
    await _checkConnectivity();
    return await _dio.post(path, data: data);
  }

  // PUT request
  Future<Response> put(String path, {dynamic data}) async {
    await _checkConnectivity();
    return await _dio.put(path, data: data);
  }

  // DELETE request
  Future<Response> delete(String path) async {
    await _checkConnectivity();
    return await _dio.delete(path);
  }

  // Upload file
  Future<Response> uploadFile(String path, String filePath) async {
    await _checkConnectivity();
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    return await _dio.post(path, data: formData);
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
        message: 'No internet connection',
      );
    }
  }
}
