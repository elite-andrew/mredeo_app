import 'package:dio/dio.dart';
import 'package:redeo_app/config/app_config.dart';
import 'package:redeo_app/data/models/payment_model.dart';
import 'api_service.dart';

class PaymentService {
  final ApiService _apiService = ApiService();

  // Make payment
  Future<Map<String, dynamic>> makePayment({
    required String contributionTypeId,
    required double amount,
    required TelcoProvider telco,
    required String phoneNumber,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.makePayment,
        data: {
          'contribution_type_id': contributionTypeId,
          'amount_paid': amount,
          'telco': telco.name,
          'phone_number_used': phoneNumber,
        },
      );

      return {
        'success': true,
        'data': response.data,
        'message': 'Payment initiated successfully',
      };
    } catch (e) {
      return _handleError(e);
    }
  }

  // Get payment history
  Future<Map<String, dynamic>> getPaymentHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.paymentHistory,
        queryParameters: {'page': page, 'limit': limit},
      );

      return {'success': true, 'data': response.data};
    } catch (e) {
      return _handleError(e);
    }
  }

  // Get payment details
  Future<Map<String, dynamic>> getPaymentDetails(String paymentId) async {
    try {
      final response = await _apiService.get(
        '${ApiEndpoints.paymentDetails}/$paymentId',
      );

      return {'success': true, 'data': response.data};
    } catch (e) {
      return _handleError(e);
    }
  }

  // Get contribution types
  Future<Map<String, dynamic>> getContributionTypes() async {
    try {
      final response = await _apiService.get(ApiEndpoints.contributions);

      return {'success': true, 'data': response.data};
    } catch (e) {
      return _handleError(e);
    }
  }

  // Check payment status
  Future<Map<String, dynamic>> checkPaymentStatus(
    String transactionReference,
  ) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.payments,
        queryParameters: {'transaction_reference': transactionReference},
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
