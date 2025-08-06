import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:redeo_app/config/app_config.dart';
import 'package:redeo_app/data/services/auth_interceptor.dart';
import 'package:redeo_app/data/services/retry_interceptor.dart';
import 'package:redeo_app/data/services/cache_interceptor.dart';

class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Connection pool for better performance
  static final Map<String, Dio> _connectionPool = {};
  static const int _maxConnections = 5;

  ApiService() {
    _dio = _getOrCreateDio();
    _setupInterceptors();
  }

  Dio _getOrCreateDio() {
    final key = AppConfig.baseUrl;
    if (_connectionPool.containsKey(key) &&
        _connectionPool.length < _maxConnections) {
      return _connectionPool[key]!;
    }

    final dio = Dio();
    dio.options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.apiTimeout,
      receiveTimeout: AppConfig.apiTimeout,
      sendTimeout: AppConfig.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
      },
      // Enable HTTP/2 for better performance
      // httpClientAdapter: HttpClientAdapter(), // Removed for compatibility
      // Optimize for mobile networks
      validateStatus: (status) => status != null && status < 500,
    );

    // Add to connection pool
    if (_connectionPool.length < _maxConnections) {
      _connectionPool[key] = dio;
    }

    return dio;
  }

  void _setupInterceptors() {
    // Add interceptors in order of execution
    _dio.interceptors.add(CacheInterceptor());
    _dio.interceptors.add(AuthInterceptor(_dio, _storage));
    _dio.interceptors.add(RetryInterceptor());

    // Optimized logging interceptor
    if (AppConfig.enableLogging) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false, // Disable request body logging for performance
          responseBody: false, // Disable response body logging for performance
          logPrint: (obj) {
            if (AppConfig.enableLogging) {
              developer.log(obj.toString(), name: 'ApiService');
            }
          },
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }

    // Performance monitoring interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.extra['startTime'] = DateTime.now().millisecondsSinceEpoch;
          handler.next(options);
        },
        onResponse: (response, handler) {
          final startTime = response.requestOptions.extra['startTime'] as int?;
          if (startTime != null) {
            final duration = DateTime.now().millisecondsSinceEpoch - startTime;
            if (duration > 1000) {
              // Log slow requests (>1s)
              developer.log(
                'Slow API request: ${response.requestOptions.path} took ${duration}ms',
                name: 'ApiService',
              );
            }
          }
          handler.next(response);
        },
        onError: (error, handler) {
          final startTime = error.requestOptions.extra['startTime'] as int?;
          if (startTime != null) {
            final duration = DateTime.now().millisecondsSinceEpoch - startTime;
            developer.log(
              'API error: ${error.requestOptions.path} failed after ${duration}ms',
              name: 'ApiService',
            );
          }
          handler.next(error);
        },
      ),
    );
  }

  // Optimized GET request with caching
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool useCache = true,
    Duration? cacheDuration,
  }) async {
    await _checkConnectivity();

    final options = Options(
      extra: {'useCache': useCache, 'cacheDuration': cacheDuration},
    );

    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Optimized POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool useCache = false,
  }) async {
    await _checkConnectivity();

    final options = Options(extra: {'useCache': useCache});

    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Optimized PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    await _checkConnectivity();
    return await _dio.put(path, data: data, queryParameters: queryParameters);
  }

  // Optimized DELETE request
  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    await _checkConnectivity();
    return await _dio.delete(path, queryParameters: queryParameters);
  }

  // Optimized file upload with progress tracking
  Future<Response> uploadFile(
    String path,
    String filePath, {
    ProgressCallback? onProgress,
    Map<String, dynamic>? extraData,
  }) async {
    await _checkConnectivity();

    // Check file size before upload
    final file = File(filePath);
    final fileSize = await file.length();

    if (fileSize > 5 * 1024 * 1024) {
      // 5MB limit
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.badResponse,
        message: 'File size exceeds 5MB limit',
      );
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
      if (extraData != null) ...extraData,
    });

    return await _dio.post(
      path,
      data: formData,
      onSendProgress: onProgress,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
  }

  // Batch requests for better performance
  Future<List<Response>> batchRequests(
    List<Future<Response> Function()> requests,
  ) async {
    await _checkConnectivity();

    final futures = requests.map((request) => request());
    return await Future.wait(futures);
  }

  // Optimized connectivity check with caching
  static ConnectivityResult? _lastConnectivityResult;
  static DateTime? _lastConnectivityCheck;

  Future<void> _checkConnectivity() async {
    final now = DateTime.now();

    // Cache connectivity result for 5 seconds to avoid frequent checks
    if (_lastConnectivityCheck != null &&
        now.difference(_lastConnectivityCheck!).inSeconds < 5) {
      if (_lastConnectivityResult == ConnectivityResult.none) {
        throw DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
          message: 'No internet connection',
        );
      }
      return;
    }

    _lastConnectivityCheck = now;
    _lastConnectivityResult = await Connectivity().checkConnectivity();

    if (_lastConnectivityResult == ConnectivityResult.none) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
        message: 'No internet connection',
      );
    }
  }

  // Clear connection pool
  static void clearConnectionPool() {
    for (final dio in _connectionPool.values) {
      dio.close();
    }
    _connectionPool.clear();
  }

  // Get connection pool status
  static Map<String, dynamic> getConnectionPoolStatus() {
    return {
      'activeConnections': _connectionPool.length,
      'maxConnections': _maxConnections,
      'connections': _connectionPool.keys.toList(),
    };
  }
}
