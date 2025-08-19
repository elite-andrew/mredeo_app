import 'package:dio/dio.dart';
import 'package:mredeo_app/data/services/api_client.dart';
import 'package:mredeo_app/data/models/admin_metrics.dart';
import 'package:mredeo_app/data/models/time_bucket_point.dart';
import 'package:mredeo_app/data/models/pending_notification.dart';

class AdminRepository {
  final ApiClient apiClient;

  AdminRepository({required this.apiClient});

  Future<AdminMetrics> fetchMetrics() async {
    try {
      final json = await apiClient.get('/api/admin/metrics');
      return AdminMetrics.fromJson(json);
    } on DioException catch (e) {
      throw _handleRepositoryError(e, 'Failed to fetch admin metrics');
    } catch (e) {
      throw Exception('Unexpected error fetching metrics: $e');
    }
  }

  Future<List<TimeBucketPoint>> fetchContributionSeries({
    required String type,
    required String scale,
  }) async {
    try {
      final json = await apiClient.get(
        '/api/admin/reports/series?type=$type&scale=$scale',
      );

      final List points = json['points'] ?? [];
      return points.map((p) => TimeBucketPoint.fromJson(p)).toList();
    } on DioException catch (e) {
      throw _handleRepositoryError(e, 'Failed to fetch contribution series');
    } catch (e) {
      throw Exception('Unexpected error fetching contribution series: $e');
    }
  }

  Future<List<PendingNotification>> fetchPendingNotifications({
    int limit = 20,
  }) async {
    try {
      final json = await apiClient.get(
        '/api/admin/notifications/pending?limit=$limit',
      );

      final List items = json['items'] ?? [];
      return items.map((n) => PendingNotification.fromJson(n)).toList();
    } on DioException catch (e) {
      throw _handleRepositoryError(e, 'Failed to fetch pending notifications');
    } catch (e) {
      throw Exception('Unexpected error fetching notifications: $e');
    }
  }

  Exception _handleRepositoryError(DioException dioError, String context) {
    final statusCode = dioError.response?.statusCode;

    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('$context: Request timeout');

      case DioExceptionType.connectionError:
        return Exception('$context: Network connection error');

      case DioExceptionType.badResponse:
        if (statusCode != null) {
          switch (statusCode) {
            case 401:
              return Exception('$context: Unauthorized access');
            case 403:
              return Exception('$context: Access forbidden');
            case 404:
              return Exception('$context: Resource not found');
            case 500:
              return Exception('$context: Internal server error');
            default:
              return Exception('$context: Server error ($statusCode)');
          }
        }
        return Exception('$context: Bad server response');

      case DioExceptionType.cancel:
        return Exception('$context: Request cancelled');

      case DioExceptionType.badCertificate:
        return Exception('$context: Certificate verification failed');

      case DioExceptionType.unknown:
        return Exception('$context: ${dioError.message ?? "Unknown error"}');
    }
  }
}
