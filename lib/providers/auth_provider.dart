import 'package:flutter/material.dart';
import 'package:redeo_app/data/services/auth_service.dart';
import 'package:redeo_app/data/services/firebase_auth_service.dart';
import 'package:redeo_app/data/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuthService _firebaseAuth = FirebaseAuthService();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  User? _currentUser;
  String? _errorMessage;
  String? _phoneNumber; // For OTP flow
  int? _resendToken; // Firebase forceResendingToken
  Map<String, String>?
  _pendingPhoneSignup; // fullName, username, password, phoneNumber

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get phoneNumber => _phoneNumber;
  Map<String, String>? get pendingPhoneSignup => _pendingPhoneSignup;
  int? get resendToken => _resendToken;

  // Cache phone signup details until OTP verification completes
  void setPendingPhoneSignup({
    required String fullName,
    required String username,
    required String password,
    required String phoneNumber,
  }) {
    _pendingPhoneSignup = {
      'fullName': fullName,
      'username': username,
      'password': password,
      'phoneNumber': phoneNumber,
    };
  }

  // Start Firebase phone verification for signup
  Future<Map<String, dynamic>> startPhoneSignupVerification({
    required String phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();
    final res = await _firebaseAuth.startPhoneVerification(
      phoneNumber: phoneNumber,
    );
    _setLoading(false);
    if (res['success'] == true) {
      _phoneNumber = phoneNumber;
      _resendToken = res['resendToken'] as int?;
      return res;
    }
    final msg = res['message'] ?? 'Failed to start phone verification';
    _setError(msg);
    return {'success': false, 'message': msg};
  }

  // Start Firebase phone verification for login
  Future<Map<String, dynamic>> startPhoneLoginVerification({
    required String phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();
    final res = await _firebaseAuth.startPhoneVerification(
      phoneNumber: phoneNumber,
    );
    _setLoading(false);
    if (res['success'] == true) {
      _phoneNumber = phoneNumber;
      _resendToken = res['resendToken'] as int?;
      return res;
    }
    final msg = res['message'] ?? 'Failed to start phone verification';
    _setError(msg);
    return {'success': false, 'message': msg};
  }

  // Confirm Firebase OTP for signup
  Future<Map<String, dynamic>> confirmPhoneSignupOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    _setLoading(true);
    _clearError();
    final res = await _firebaseAuth.confirmSmsCode(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    _setLoading(false);
    if (res['success'] == true) {
      return {'success': true};
    }
    final msg = res['message'] ?? 'Invalid OTP';
    _setError(msg);
    return {'success': false, 'message': msg};
  }

  // Confirm Firebase OTP for login and set session
  Future<Map<String, dynamic>> confirmPhoneLoginOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    _setLoading(true);
    _clearError();
    final res = await _firebaseAuth.confirmSmsCode(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    if (res['success'] == true) {
      // Update provider session from Firebase currentUser
      final userData = await _firebaseAuth.getCurrentUser();
      if (userData != null && userData['success'] == true) {
        _currentUser = User.fromJson(userData['data']['user']);
      }
      _isLoggedIn = true;
      _resendToken = null; // clear after success
      _setLoading(false);
      notifyListeners();
      return {'success': true};
    }
    _setLoading(false);
    final msg = res['message'] ?? 'Invalid OTP';
    _setError(msg);
    return {'success': false, 'message': msg};
  }

  // Resend OTP via Firebase
  Future<Map<String, dynamic>> resendPhoneOtp() async {
    if (_phoneNumber == null) {
      return {'success': false, 'message': 'No phone number to resend to'};
    }
    _setLoading(true);
    _clearError();
    final res = await _firebaseAuth.resendPhoneVerification(
      phoneNumber: _phoneNumber!,
      forceResendingToken: _resendToken,
    );
    _setLoading(false);
    if (res['success'] == true) {
      _resendToken = res['resendToken'] as int?;
      return res;
    }
    final msg = res['message'] ?? 'Failed to resend OTP';
    _setError(msg);
    return {'success': false, 'message': msg};
  }

  // Complete backend signup after Firebase phone verification
  Future<Map<String, dynamic>> completePhoneSignup() async {
    if (_pendingPhoneSignup == null) {
      return {'success': false, 'message': 'No pending signup data'};
    }
    _setLoading(true);
    _clearError();
    final data = _pendingPhoneSignup!;
    final result = await _authService.signup(
      fullName: data['fullName']!,
      username: data['username']!,
      phoneNumber: data['phoneNumber']!,
      password: data['password']!,
      email: null,
    );
    _setLoading(false);
    if (result['success'] == true) {
      // Clear pending data
      _pendingPhoneSignup = null;
      return {'success': true, 'message': result['message']};
    }
    final msg = result['message'] ?? 'Signup failed';
    _setError(msg);
    return {'success': false, 'message': msg};
  }

  // Initialize auth state using Firebase only
  Future<void> initializeAuth() async {
    _setLoading(true);
    _isLoggedIn = await _firebaseAuth.isLoggedIn();
    if (_isLoggedIn) {
      final userData = await _firebaseAuth.getCurrentUser();
      if (userData != null && userData['success'] == true) {
        _currentUser = User.fromJson(userData['data']['user']);
      }
    }
    _setLoading(false);
  }

  // Login: email via Firebase email/password; phone via Firebase OTP
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    _setLoading(true);
    _clearError();

    // Email path via Firebase
    final isEmail = RegExp(
      r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$',
    ).hasMatch(identifier);
    if (isEmail) {
      final fbRes = await _firebaseAuth.signInWithEmail(
        email: identifier,
        password: password,
      );
      if (fbRes['success'] == true) {
        final user = fbRes['data']?['user'] as Map<String, dynamic>?;
        final verified = (user?['email_verified'] as bool?) ?? true;
        if (!verified) {
          _setLoading(false);
          return {
            'success': false,
            'requiresVerification': true,
            'message': 'Please verify your email before logging in.',
          };
        }
        _isLoggedIn = true;
        if (user != null) _currentUser = User.fromJson(user);
        _setLoading(false);
        notifyListeners();
        return {'success': true, 'requiresOtp': false};
      } else {
        _setError(fbRes['message'] ?? 'Login failed');
        _setLoading(false);
        return {'success': false, 'message': fbRes['message']};
      }
    }
    // Phone path via Firebase OTP
    final isPhone = RegExp(r'^(\+\d{6,15}|0\d{9,})$').hasMatch(identifier);
    if (isPhone) {
      _phoneNumber = identifier;
      _setLoading(false);
      return {'success': true, 'requiresOtp': true};
    }

    // Unsupported identifier format
    _setLoading(false);
    return {'success': false, 'message': 'Invalid identifier'};
  }

  // Removed legacy verifyLoginOtp; use confirmPhoneLoginOtp

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
    // If email is provided, prefer Firebase email sign-up
    if (email != null && email.isNotEmpty) {
      final fbRes = await _firebaseAuth.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      _setLoading(false);
      if (fbRes['success'] == true) {
        return {
          'success': true,
          'message':
              fbRes['message'] ??
              'Registration successful. Check your email to verify.',
        };
      } else {
        final msg = fbRes['message'] ?? 'Registration failed';
        _setError(msg);
        return {'success': false, 'message': msg};
      }
    }

    // Fallback to legacy signup (phone-based flow)
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

  // Removed legacy verifySignupOtp; use Firebase verification and completePhoneSignup

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

  // Forgot password via email (Firebase)
  Future<Map<String, dynamic>> forgotPasswordByEmail(String email) async {
    _setLoading(true);
    _clearError();
    final res = await _firebaseAuth.sendPasswordResetEmail(email);
    _setLoading(false);
    if (res['success'] == true) {
      return res;
    }
    final msg = res['message'] ?? 'Failed to send password reset email';
    _setError(msg);
    return {'success': false, 'message': msg};
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);

    await _authService.logout();
    try {
      await _firebaseAuth.signOut();
    } catch (_) {}

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
