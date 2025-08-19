import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:mredeo_app/data/models/admin_metrics.dart';
import 'package:mredeo_app/data/models/time_bucket_point.dart';
import 'package:mredeo_app/data/models/pending_notification.dart';
import 'package:mredeo_app/data/models/payment_model.dart';
import 'package:mredeo_app/data/repositories/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository repository;

  AdminProvider({required this.repository});

  AdminMetrics? metrics;
  List<TimeBucketPoint> series = [];
  List<PendingNotification> pending = [];
  List<IssuedPayment> issuedPayments = [];
  String selectedType = "yearly"; // default filter
  String scale = "monthly"; // default scale
  bool loading = false;
  bool isLoading = false;
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

  Future<void> loadIssuedPayments() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // For now, let's create some sample data for testing
      // Later this will be replaced with actual API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      issuedPayments = [
        IssuedPayment(
          id: '1',
          issuedBy: 'admin',
          issuedTo: 'user1',
          memberName: 'John Doe',
          memberPhone: '+255712345678',
          amount: 150000,
          purpose: 'Emergency assistance',
          type: 'Emergency Fund',
          description: 'Medical emergency support',
          transactionReference: 'TXN001',
          issuedAt: DateTime.now().subtract(const Duration(days: 2)),
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        IssuedPayment(
          id: '2',
          issuedBy: 'admin',
          issuedTo: 'user2',
          memberName: 'Jane Smith',
          memberPhone: '+255712345679',
          amount: 75000,
          purpose: 'Monthly contribution refund',
          type: 'Monthly Contribution',
          description: 'Refund for overpayment',
          transactionReference: 'TXN002',
          issuedAt: DateTime.now().subtract(const Duration(days: 5)),
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        IssuedPayment(
          id: '3',
          issuedBy: 'admin',
          issuedTo: 'user3',
          memberName: 'Peter Johnson',
          memberPhone: '+255712345680',
          amount: 200000,
          purpose: 'Project completion bonus',
          type: 'Project Fund',
          description: 'Completion of community project',
          transactionReference: 'TXN003',
          issuedAt: DateTime.now().subtract(const Duration(days: 10)),
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        IssuedPayment(
          id: '4',
          issuedBy: 'admin',
          issuedTo: 'user4',
          memberName: 'Mary Wilson',
          memberPhone: '+255712345681',
          amount: 50000,
          purpose: 'Welfare support',
          type: 'Welfare',
          description: 'Family welfare assistance',
          transactionReference: 'TXN004',
          issuedAt: DateTime.now().subtract(const Duration(days: 15)),
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
      ];

      // Later, replace above with:
      // issuedPayments = await repository.fetchIssuedPayments();
    } on DioException catch (dioError) {
      errorMessage = _handleDioError(dioError);
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
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
