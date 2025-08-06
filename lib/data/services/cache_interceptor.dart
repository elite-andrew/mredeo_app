import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheInterceptor extends Interceptor {
  static const String _cachePrefix = 'api_cache_';
  static const Duration _defaultCacheDuration = Duration(minutes: 5);

  // In-memory cache for faster access
  static final Map<String, _CacheEntry> _memoryCache = {};
  static const int _maxMemoryCacheSize = 100;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final useCache = options.extra['useCache'] as bool? ?? false;

    if (!useCache || options.method != 'GET') {
      handler.next(options);
      return;
    }

    final cacheKey = _generateCacheKey(options);
    final cachedResponse = await _getCachedResponse(cacheKey);

    if (cachedResponse != null) {
      // Return cached response
      handler.resolve(cachedResponse);
      return;
    }

    // Continue with request
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final useCache =
        response.requestOptions.extra['useCache'] as bool? ?? false;

    if (!useCache || response.requestOptions.method != 'GET') {
      handler.next(response);
      return;
    }

    // Cache successful GET responses
    if (response.statusCode == 200) {
      final cacheKey = _generateCacheKey(response.requestOptions);
      final cacheDuration =
          response.requestOptions.extra['cacheDuration'] as Duration? ??
          _defaultCacheDuration;

      await _cacheResponse(cacheKey, response, cacheDuration);
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Try to serve cached response on error for GET requests
    if (err.requestOptions.method == 'GET') {
      final cacheKey = _generateCacheKey(err.requestOptions);
      final cachedResponse = await _getCachedResponse(cacheKey);

      if (cachedResponse != null) {
        // Return cached response with a note
        cachedResponse.data = {
          'cached': true,
          'original_error': err.message,
          'data': cachedResponse.data,
        };
        handler.resolve(cachedResponse);
        return;
      }
    }

    handler.next(err);
  }

  String _generateCacheKey(RequestOptions options) {
    final url = options.uri.toString();
    final queryParams =
        options.queryParameters.isNotEmpty
            ? json.encode(options.queryParameters)
            : '';
    return '$_cachePrefix${url.hashCode}_${queryParams.hashCode}';
  }

  Future<Response?> _getCachedResponse(String cacheKey) async {
    // Check memory cache first
    final memoryEntry = _memoryCache[cacheKey];
    if (memoryEntry != null && !memoryEntry.isExpired) {
      return memoryEntry.response;
    }

    // Check persistent cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(cacheKey);

      if (cachedData != null) {
        final entry = _CacheEntry.fromJson(cachedData);

        if (!entry.isExpired) {
          // Add to memory cache
          _addToMemoryCache(cacheKey, entry);
          return entry.response;
        } else {
          // Remove expired cache
          await prefs.remove(cacheKey);
        }
      }
    } catch (e) {
      // Ignore cache errors
    }

    return null;
  }

  Future<void> _cacheResponse(
    String cacheKey,
    Response response,
    Duration duration,
  ) async {
    final entry = _CacheEntry(
      response: response,
      expiresAt: DateTime.now().add(duration),
    );

    // Add to memory cache
    _addToMemoryCache(cacheKey, entry);

    // Add to persistent cache
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, entry.toJson());
    } catch (e) {
      // Ignore cache errors
    }
  }

  void _addToMemoryCache(String key, _CacheEntry entry) {
    // Remove oldest entries if cache is full
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      final oldestKey = _memoryCache.keys.first;
      _memoryCache.remove(oldestKey);
    }

    _memoryCache[key] = entry;
  }

  // Clear all cache
  static Future<void> clearCache() async {
    _memoryCache.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      // Ignore cache errors
    }
  }

  // Clear cache for specific URL pattern
  static Future<void> clearCacheForPattern(String pattern) async {
    final keysToRemove = <String>[];

    // Remove from memory cache
    _memoryCache.keys.where((key) => key.contains(pattern)).forEach((key) {
      keysToRemove.add(key);
      _memoryCache.remove(key);
    });

    // Remove from persistent cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where(
        (key) => key.startsWith(_cachePrefix) && key.contains(pattern),
      );
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      // Ignore cache errors
    }
  }

  // Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'memoryCacheSize': _memoryCache.length,
      'maxMemoryCacheSize': _maxMemoryCacheSize,
      'memoryCacheKeys': _memoryCache.keys.toList(),
    };
  }
}

class _CacheEntry {
  final Response response;
  final DateTime expiresAt;

  _CacheEntry({required this.response, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  String toJson() {
    return json.encode({
      'response': {
        'statusCode': response.statusCode,
        'headers': response.headers.map,
        'data': response.data,
      },
      'expiresAt': expiresAt.toIso8601String(),
    });
  }

  factory _CacheEntry.fromJson(String jsonString) {
    final data = json.decode(jsonString);
    final responseData = data['response'];

    final response = Response(
      statusCode: responseData['statusCode'],
      headers: Headers.fromMap(responseData['headers']),
      data: responseData['data'],
      requestOptions: RequestOptions(path: ''),
    );

    return _CacheEntry(
      response: response,
      expiresAt: DateTime.parse(data['expiresAt']),
    );
  }
}
