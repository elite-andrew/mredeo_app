import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:mredeo_app/data/models/admin_metrics.dart';
import 'package:mredeo_app/data/models/time_bucket_point.dart';
import 'package:mredeo_app/data/models/pending_notification.dart';
import 'package:mredeo_app/data/repositories/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository repository;

  AdminProvider({required this.repository});

  AdminMetrics? metrics;
  List<TimeBucketPoint> series = [];
  List<PendingNotification> pending = [];
  String selectedType = "yearly"; // default filter
  String scale = "monthly"; // default scale
  bool loading = false;
  String? errorMessage;

  Future<void> refreshAll() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      metrics = await repository.fetchMetrics();
      series = await repository.fetchContributionSeries(
        type: selectedType,
        scale: scale,
      );
      pending = await repository.fetchPendingNotifications();
    } on DioException catch (dioError) {
      errorMessage = _handleDioError(dioError);
    } catch (e) {
      errorMessage = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  void setScale(String newScale) {
    scale = newScale;
    _reloadSeries();
  }

  void setType(String newType) {
    selectedType = newType;
    _reloadSeries();
  }

  Future<void> _reloadSeries() async {
    try {
      series = await repository.fetchContributionSeries(
        type: selectedType,
        scale: scale,
      );
    } on DioException catch (dioError) {
      errorMessage = _handleDioError(dioError);
    } catch (e) {
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final statusMessage = error.response?.statusMessage;
        return 'Server error ($statusCode): ${statusMessage ?? 'Unknown error'}';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.badCertificate:
        return 'Certificate error. Please contact support.';
      case DioExceptionType.unknown:
        return error.message ?? 'An unexpected error occurred.';
    }
  }

  // Helper method to clear error state
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  // Helper method to check if data is loaded
  bool get hasData => metrics != null && series.isNotEmpty;
}
