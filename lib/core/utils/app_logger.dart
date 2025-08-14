import 'package:flutter/foundation.dart';
// Uncomment these when you're ready for production integration:
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';

/// Comprehensive app-wide logging utility
/// Handles all logging needs from development to production
/// Integrates with crash reporting and analytics services
class AppLogger {
  static const String _tag = 'MREDEO';

  // Production logging configuration
  static const bool _enableProductionLogs = true;
  static const bool _enableProductionAnalytics = true;

  // Uncomment these when you add the packages:
  // static final _crashlytics = FirebaseCrashlytics.instance;
  // static final _analytics = FirebaseAnalytics.instance;

  /// Log debug messages (only in debug mode)
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] DEBUG: $message');
    }
  }

  /// Log info messages (available in production)
  static void info(String message, [String? tag]) {
    final logMessage = '[$_tag${tag != null ? ':$tag' : ''}] INFO: $message';

    if (kDebugMode) {
      debugPrint(logMessage);
    } else if (_enableProductionLogs) {
      // In production, could send to analytics or logging service
      debugPrint(logMessage);
    }
  }

  /// Log warning messages (available in production)
  static void warning(String message, [String? tag]) {
    final logMessage = '[$_tag${tag != null ? ':$tag' : ''}] WARNING: $message';

    if (kDebugMode) {
      debugPrint(logMessage);
    } else if (_enableProductionLogs) {
      // In production, should definitely be logged for monitoring
      debugPrint(logMessage);
      // TODO: Send to monitoring service (Crashlytics, Sentry, etc.)
    }
  }

  /// Log error messages (ALWAYS shown - critical for production)
  static void error(
    String message, [
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final logMessage = '[$_tag${tag != null ? ':$tag' : ''}] ERROR: $message';

    // Always log errors, even in production
    debugPrint(logMessage);

    if (error != null) {
      debugPrint('Error details: $error');
    }

    if (stackTrace != null && kDebugMode) {
      // Only print full stack trace in debug mode to avoid spam
      debugPrint('Stack trace: $stackTrace');
    }

    // In production, send to crash reporting service
    if (!kDebugMode) {
      _reportErrorToService(message, error, stackTrace);
    }
  }

  /// Report errors to crash reporting service
  static void _reportErrorToService(
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    // Uncomment when you add firebase_crashlytics package:
    // _crashlytics.recordError(error, stackTrace, reason: message, fatal: false);

    // For now, just ensure it's logged
    debugPrint('CRASH REPORT: $message');
  }

  /// Log API requests/responses
  static void api(String message, [String? endpoint]) {
    final logMessage =
        '[$_tag:API${endpoint != null ? ':$endpoint' : ''}] $message';

    if (kDebugMode) {
      debugPrint(logMessage);
    } else if (_enableProductionLogs) {
      // In production, API logs can help debug user issues
      debugPrint(logMessage);
    }
  }

  /// Log provider state changes (debug mode only to avoid spam)
  static void provider(String message, String providerName) {
    if (kDebugMode) {
      debugPrint('[$_tag:PROVIDER:$providerName] $message');
    }
  }

  /// Log user actions (valuable for analytics)
  static void userAction(String action, [Map<String, dynamic>? properties]) {
    final logMessage = '[$_tag:USER_ACTION] $action';

    if (kDebugMode) {
      debugPrint(logMessage);
      if (properties != null) {
        debugPrint('Properties: $properties');
      }
    } else if (_enableProductionLogs) {
      debugPrint(logMessage);
      _logAnalyticsEvent(action, properties);
    }
  }

  /// Log analytics events to service
  static void _logAnalyticsEvent(
    String action,
    Map<String, dynamic>? properties,
  ) {
    // Uncomment when you add firebase_analytics package:
    // _analytics.logEvent(
    //   name: action,
    //   parameters: properties?.cast<String, Object>(),
    // );

    // For now, just ensure it's logged
    debugPrint('ANALYTICS: $action ${properties ?? ''}');
  }

  /// Set user context for better error tracking and analytics
  static void setUserContext(String userId, String role) {
    if (kDebugMode) {
      debugPrint('[$_tag:CONTEXT] Setting user context: $userId ($role)');
    }

    if (!kDebugMode) {
      // Uncomment when you add the packages:
      // _crashlytics.setUserIdentifier(userId);
      // _crashlytics.setCustomKey('user_role', role);
      // _analytics.setUserId(id: userId);
      // _analytics.setUserProperty(name: 'role', value: role);

      debugPrint('USER_CONTEXT: $userId ($role)');
    }
  }

  /// Log performance metrics
  static void performance(String metric, int durationMs, [String? tag]) {
    final logMessage =
        '[$_tag:PERFORMANCE${tag != null ? ':$tag' : ''}] $metric took ${durationMs}ms';

    if (kDebugMode) {
      debugPrint(logMessage);
    } else if (_enableProductionLogs && durationMs > 1000) {
      // Only log slow operations in production
      debugPrint(logMessage);
      _reportPerformanceMetric(metric, durationMs, tag);
    }
  }

  /// Report performance metrics to monitoring service
  static void _reportPerformanceMetric(
    String metric,
    int durationMs,
    String? tag,
  ) {
    // Uncomment when you add firebase_performance package:
    // final trace = FirebasePerformance.instance.newTrace(metric);
    // trace.start();
    // await Future.delayed(Duration(milliseconds: durationMs));
    // trace.stop();

    debugPrint('PERFORMANCE_METRIC: $metric ${durationMs}ms ${tag ?? ''}');
  }

  /// Initialize logging services (call this in main.dart)
  static Future<void> initialize() async {
    if (kDebugMode) {
      debugPrint('[$_tag] Logger initialized in DEBUG mode');
    } else {
      debugPrint('[$_tag] Logger initialized in PRODUCTION mode');

      // Uncomment when you add the packages:
      // FlutterError.onError = (errorDetails) {
      //   _crashlytics.recordFlutterFatalError(errorDetails);
      // };
      //
      // PlatformDispatcher.instance.onError = (error, stack) {
      //   _crashlytics.recordError(error, stack, fatal: true);
      //   return true;
      // };
    }
  }
}
