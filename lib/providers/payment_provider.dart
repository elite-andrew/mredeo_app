import 'package:flutter/material.dart';
import 'package:mredeo_app/data/services/payment_service.dart';
import 'package:mredeo_app/data/models/payment_model.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  bool _isLoading = false;
  String? _errorMessage;
  List<Payment> _paymentHistory = [];
  List<ContributionType> _contributionTypes = [];
  Payment? _currentPayment;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Payment> get paymentHistory => _paymentHistory;
  List<ContributionType> get contributionTypes => _contributionTypes;
  Payment? get currentPayment => _currentPayment;

  // Load contribution types
  Future<void> loadContributionTypes() async {
    _setLoading(true);
    _clearError();

    final result = await _paymentService.getContributionTypes();

    if (result['success'] && result['data'] != null) {
      final data = result['data'];
      List<dynamic> contributionList;

      // Handle different response structures
      if (data is List) {
        contributionList = data;
      } else if (data is Map && data['data'] is List) {
        contributionList = data['data'];
      } else {
        contributionList = [];
      }

      _contributionTypes =
          contributionList
              .map((json) => ContributionType.fromJson(json))
              .toList();
    } else {
      _setError(result['message'] ?? 'Failed to load contribution types');
    }

    _setLoading(false);
  }

  // Load payment history
  Future<void> loadPaymentHistory({int page = 1}) async {
    _setLoading(true);
    _clearError();

    final result = await _paymentService.getPaymentHistory(page: page);

    if (result['success']) {
      final payments =
          (result['data']['data']['payments'] as List)
              .map((json) => Payment.fromJson(json))
              .toList();

      if (page == 1) {
        _paymentHistory = payments;
      } else {
        _paymentHistory.addAll(payments);
      }
    } else {
      // Don't show error for empty data - just set empty list
      if (result['message']?.toString().toLowerCase().contains('no') == true ||
          result['message']?.toString().toLowerCase().contains('empty') ==
              true) {
        _paymentHistory = [];
      } else {
        _setError(result['message']);
      }
    }

    _setLoading(false);
  }

  // Make payment
  Future<Map<String, dynamic>> makePayment({
    required String contributionTypeId,
    required double amount,
    required TelcoProvider telco,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _paymentService.makePayment(
      contributionTypeId: contributionTypeId,
      amount: amount,
      telco: telco,
      phoneNumber: phoneNumber,
    );

    _setLoading(false);

    if (result['success']) {
      _currentPayment = Payment.fromJson(result['data']['data']);
      // Refresh payment history
      loadPaymentHistory();
      return {'success': true, 'payment': _currentPayment};
    } else {
      _setError(result['message']);
      return {'success': false, 'message': result['message']};
    }
  }

  // Get payment details
  Future<Payment?> getPaymentDetails(String paymentId) async {
    _setLoading(true);
    _clearError();

    final result = await _paymentService.getPaymentDetails(paymentId);

    _setLoading(false);

    if (result['success']) {
      return Payment.fromJson(result['data']['data']);
    } else {
      _setError(result['message']);
      return null;
    }
  }

  // Check payment status
  Future<Map<String, dynamic>> checkPaymentStatus(
    String transactionReference,
  ) async {
    final result = await _paymentService.checkPaymentStatus(
      transactionReference,
    );

    if (result['success']) {
      final payment = Payment.fromJson(result['data']['data']);

      // Update current payment if it matches
      if (_currentPayment?.transactionReference == transactionReference) {
        _currentPayment = payment;
        notifyListeners();
      }

      // Update in payment history if exists
      final index = _paymentHistory.indexWhere(
        (p) => p.transactionReference == transactionReference,
      );
      if (index != -1) {
        _paymentHistory[index] = payment;
        notifyListeners();
      }

      return {'success': true, 'payment': payment};
    } else {
      return {'success': false, 'message': result['message']};
    }
  }

  // Get contribution type by id
  ContributionType? getContributionTypeById(String id) {
    try {
      return _contributionTypes.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }

  // Calculate total pending payments
  double get totalPendingAmount {
    return _paymentHistory
        .where((payment) => payment.paymentStatus == PaymentStatus.pending)
        .fold(0.0, (sum, payment) => sum + payment.amountPaid);
  }

  // Calculate total paid amount
  double get totalPaidAmount {
    return _paymentHistory
        .where((payment) => payment.paymentStatus == PaymentStatus.success)
        .fold(0.0, (sum, payment) => sum + payment.amountPaid);
  }

  // Get payments by status
  List<Payment> getPaymentsByStatus(PaymentStatus status) {
    return _paymentHistory
        .where((payment) => payment.paymentStatus == status)
        .toList();
  }

  // Get recent payments (last 5)
  List<Payment> get recentPayments {
    final sortedPayments = List<Payment>.from(_paymentHistory)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedPayments.take(5).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearCurrentPayment() {
    _currentPayment = null;
    notifyListeners();
  }
}
