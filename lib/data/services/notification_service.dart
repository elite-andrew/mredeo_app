import 'package:dio/dio.dart';
import 'package:redeo_app/config/app_config.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

  // Get notifications
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.notifications,
        queryParameters: {'page': page, 'limit': limit},
      );

      return {'success': true, 'data': response.data};
    } catch (e) {
      return _handleError(e);
    }
  }

  // Mark notification as read
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    try {
      final response = await _apiService.put(
        '${ApiEndpoints.markAsRead}/$notificationId/read',
      );

      return {
        'success': true,
        'data': response.data,
        'message': 'Notification marked as read',
      };
    } catch (e) {
      return _handleError(e);
    }
  }

  // Mark all notifications as read
  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final response = await _apiService.put(
        '${ApiEndpoints.notifications}/read-all',
      );

      return {
        'success': true,
        'data': response.data,
        'message': 'All notifications marked as read',
      };
    } catch (e) {
      return _handleError(e);
    }
  }

  // Get unread count
  Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final response = await _apiService.get(
        '${ApiEndpoints.notifications}/unread-count',
      );

      return {'success': true, 'data': response.data};
    } catch (e) {
      return _handleError(e);
    }
  }

  Map<String, dynamic> _handleError(dynamic error) {
    String message = 'An error occurred';

    if (error is DioException) {
      if (error.response?.data != null &&
          error.response!.data['message'] != null) {
        message = error.response!.data['message'];
      } else if (error.type == DioExceptionType.connectionError) {
        message = 'No internet connection';
      } else if (error.type == DioExceptionType.connectionTimeout) {
        message = 'Connection timeout';
      }
    }

    return {'success': false, 'message': message};
  }
}
