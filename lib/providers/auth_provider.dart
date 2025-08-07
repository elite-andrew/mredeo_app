import 'package:flutter/material.dart';
import 'package:redeo_app/data/services/auth_service.dart';
import 'package:redeo_app/data/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  User? _currentUser;
  String? _errorMessage;
  String? _phoneNumber; // For OTP flow

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get phoneNumber => _phoneNumber;

  // Initialize auth state
  Future<void> initializeAuth() async {
    _setLoading(true);

    _isLoggedIn = await _authService.isLoggedIn();

    if (_isLoggedIn) {
      final userData = await _authService.getCurrentUser();
      if (userData != null && userData['success'] == true) {
        _currentUser = User.fromJson(userData['data']['user']);
      }
    }

    _setLoading(false);
  }

  // Login
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.login(
      identifier: identifier,
      password: password,
    );

    if (result['success']) {
      if (result['requiresOtp']) {
        _phoneNumber = result['phoneNumber'];
        _setLoading(false);
        return {'success': true, 'requiresOtp': true};
      } else {
        _isLoggedIn = true;
        if (result['data']?['user'] != null) {
          _currentUser = User.fromJson(result['data']['user']);
        }
        _setLoading(false);
        notifyListeners();
        return {'success': true, 'requiresOtp': false};
      }
    } else {
      // Check if account needs verification
      if (result['requiresVerification'] == true) {
        _setError(result['message']);
        _setLoading(false);
        return {
          'success': false,
          'requiresVerification': true,
          'message': result['message'],
        };
      } else {
        _setError(result['message']);
        _setLoading(false);
        return {'success': false, 'message': result['message']};
      }
    }
  }

  // Verify OTP for login
  Future<Map<String, dynamic>> verifyLoginOtp(
    String phoneNumber,
    String otpCode,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.verifyOtp(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
      purpose: 'login',
    );

    if (result['success']) {
      _isLoggedIn = true;
      if (result['data']?['user'] != null) {
        _currentUser = User.fromJson(result['data']['user']);
      }
      _setLoading(false);
      notifyListeners();
      return {'success': true};
    } else {
      _setError(result['message']);
      _setLoading(false);
      return {'success': false, 'message': result['message']};
    }
  }

  // Signup
  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String username,
    String? phoneNumber,
    required String password,
    String? email,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.signup(
      fullName: fullName,
      username: username,
      phoneNumber: phoneNumber,
      password: password,
      email: email,
    );

    _setLoading(false);
    if (result['success']) {
      return {'success': true, 'message': result['message']};
    } else {
      _setError(result['message']);
      return {'success': false, 'message': result['message']};
    }
  }

  // Verify signup OTP
  Future<Map<String, dynamic>> verifySignupOtp(
    String phoneNumber,
    String otpCode,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.verifyOtp(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
      purpose: 'signup',
    );

    if (result['success']) {
      // Auto login after successful signup verification
      _isLoggedIn = true;
      if (result['data']?['user'] != null) {
        _currentUser = User.fromJson(result['data']['user']);
      }
      _setLoading(false);
      notifyListeners();
      return {'success': true, 'message': 'Account verified successfully'};
    } else {
      _setError(result['message']);
      _setLoading(false);
      return {'success': false, 'message': result['message']};
    }
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(String phoneNumber) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.forgotPassword(phoneNumber: phoneNumber);

    _setLoading(false);
    if (result['success']) {
      _phoneNumber = phoneNumber;
      return {'success': true, 'message': result['message']};
    } else {
      _setError(result['message']);
      return {'success': false, 'message': result['message']};
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword({
    required String phoneNumber,
    required String otpCode,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.resetPassword(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
      newPassword: newPassword,
    );

    _setLoading(false);
    if (result['success']) {
      return {'success': true, 'message': result['message']};
    } else {
      _setError(result['message']);
      return {'success': false, 'message': result['message']};
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);

    await _authService.logout();

    _isLoggedIn = false;
    _currentUser = null;
    _clearError();
    _setLoading(false);
    notifyListeners();
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
    notifyListeners();
  }
}
