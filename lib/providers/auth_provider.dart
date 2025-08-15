import 'package:flutter/material.dart';
import 'package:redeo_app/data/services/auth_service.dart';
import 'package:redeo_app/data/services/firebase_auth_service.dart';
import 'package:redeo_app/data/services/local_storage_service.dart';
import 'package:redeo_app/data/services/profile_service.dart';
import 'package:redeo_app/data/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuthService _firebaseAuth = FirebaseAuthService();
  final ProfileService _profileService = ProfileService();

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
    String? username, // Optional since backend generates it
    required String password,
    required String phoneNumber,
  }) {
    _pendingPhoneSignup = {
      'fullName': fullName,
      'password': password,
      'phoneNumber': phoneNumber,
    };
    // Note: username is no longer stored since backend generates it
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

    // Clear any previous user data first
    _currentUser = null;
    await LocalStorageService.clearSessionData();

    final res = await _firebaseAuth.confirmSmsCode(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    if (res['success'] == true) {
      // First set basic Firebase user data
      final userData = await _firebaseAuth.getCurrentUser();
      if (userData != null && userData['success'] == true) {
        _currentUser = User.fromJson(userData['data']['user']);
      }
      _isLoggedIn = true;

      // Wait a moment for Firebase auth state to settle
      await Future.delayed(const Duration(milliseconds: 500));

      // Then load complete profile from database (includes profile picture)
      await _loadCompleteProfile();

      // Update session timestamp on successful login
      await LocalStorageService.updateLastActiveTime();
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

  // Initialize auth state with session management
  Future<void> initializeAuth() async {
    _setLoading(true);

    try {
      // Check if this is the first launch
      final isFirstLaunch = await LocalStorageService.isFirstLaunch();
      if (isFirstLaunch) {
        // First launch - always require authentication
        await _firebaseAuth.signOut();
        await LocalStorageService.markFirstLaunchComplete();
        _isLoggedIn = false;
        _currentUser = null;
        _setLoading(false);
        return;
      }

      // Check if session has expired
      final isSessionExpired = await LocalStorageService.isSessionExpired();
      if (isSessionExpired) {
        // Session expired - sign out and require re-authentication
        await _firebaseAuth.signOut();
        await LocalStorageService.clearSessionData();
        _isLoggedIn = false;
        _currentUser = null;
        _setLoading(false);
        return;
      }

      // Check if user is still logged in Firebase
      _isLoggedIn = await _firebaseAuth.isLoggedIn();
      if (_isLoggedIn) {
        final userData = await _firebaseAuth.getCurrentUser();
        if (userData != null && userData['success'] == true) {
          _currentUser = User.fromJson(userData['data']['user']);

          // Load complete profile from database (includes profile picture)
          await _loadCompleteProfile();

          // Update session timestamp since user is still valid
          await LocalStorageService.updateLastActiveTime();
        } else {
          // Firebase user exists but data fetch failed
          _isLoggedIn = false;
          _currentUser = null;
        }
      } else {
        // User not logged in - clear any stale data
        _currentUser = null;
      }
    } catch (e) {
      // If anything goes wrong, default to requiring authentication
      _isLoggedIn = false;
      _currentUser = null;
      debugPrint('Error during auth initialization: $e');
    }

    _setLoading(false);
  }

  // Login: email via Firebase email/password; phone via Firebase OTP
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    _setLoading(true);
    _clearError();

    // Clear any previous user data first
    _currentUser = null;
    await LocalStorageService.clearSessionData();

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

        // Wait a moment for Firebase auth state to settle
        await Future.delayed(const Duration(milliseconds: 500));

        // Load complete profile from database (includes profile picture)
        await _loadCompleteProfile();

        // Update session timestamp on successful login
        await LocalStorageService.updateLastActiveTime();
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
    String? username, // Now optional since backend generates it
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

  // Change password (Firebase)
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    final res = await _firebaseAuth.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    _setLoading(false);
    if (res['success'] == true) {
      return res;
    }
    final msg = res['message'] ?? 'Failed to change password';
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

    // Clear session data
    await LocalStorageService.clearSessionData();

    _isLoggedIn = false;
    _currentUser = null;
    _clearError();
    _setLoading(false);
    notifyListeners();
  }

  // Update session activity (call this when app comes to foreground)
  Future<void> updateSessionActivity() async {
    if (_isLoggedIn) {
      await LocalStorageService.updateLastActiveTime();
    }
  }

  // Set custom session timeout (in minutes)
  Future<void> setSessionTimeout(int minutes) async {
    await LocalStorageService.setSessionTimeout(minutes);
  }

  // Get current session timeout setting
  Future<int> getSessionTimeout() async {
    return await LocalStorageService.getSessionTimeout();
  }

  // Update current user (e.g., after profile picture upload)
  void updateCurrentUser(User updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  // Public method to manually reload profile (useful for testing and recovery)
  Future<void> reloadProfile() async {
    await _loadCompleteProfile();
  }

  // Force clear all auth state (useful when switching users)
  Future<void> clearAuthState() async {
    _isLoggedIn = false;
    _currentUser = null;
    _errorMessage = null;
    _phoneNumber = null;
    _resendToken = null;
    _pendingPhoneSignup = null;

    await LocalStorageService.clearSessionData();
    notifyListeners();
  }

  // Load complete profile from database (not just Firebase data)
  Future<void> _loadCompleteProfile() async {
    int retries = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retries < maxRetries) {
      try {
        // Verify Firebase user is still current before making API call
        final firebaseUser = await _firebaseAuth.getCurrentUser();
        if (firebaseUser == null || firebaseUser['success'] != true) {
          // Firebase user no longer valid
          debugPrint('Firebase user not valid during profile load');
          break;
        }

        final result = await _profileService.getProfile();

        if (result['success'] == true && result['data'] != null) {
          if (result['data']['user'] != null) {
            final user = User.fromJson(result['data']['user']);

            debugPrint(
              'AuthProvider: Raw profile data from API: ${result['data']['user']}',
            );
            debugPrint(
              'AuthProvider: Parsed user profile picture: ${user.profilePicture}',
            );
            debugPrint(
              'AuthProvider: Generated profile picture URL: ${user.profilePictureUrl}',
            );

            // Double-check that this profile matches the current Firebase user
            final currentFirebaseUser = firebaseUser['data']['user'];
            if (currentFirebaseUser != null &&
                currentFirebaseUser['email'] != null &&
                user.email == currentFirebaseUser['email']) {
              _currentUser = user;
              debugPrint(
                'AuthProvider: Profile loaded successfully - Profile picture: ${user.profilePicture}',
              );
              notifyListeners();
              return; // Success, exit retry loop
            } else {
              debugPrint(
                'Profile email mismatch: Firebase=${currentFirebaseUser['email']}, API=${user.email}',
              );
              break; // Don't retry if users don't match
            }
          }
        }

        // If we get here, the API call succeeded but returned empty/invalid data
        break;
      } catch (e) {
        debugPrint('Error loading profile (attempt ${retries + 1}): $e');
        retries++;

        if (retries < maxRetries) {
          await Future.delayed(retryDelay);
        }
      }
    }

    // If all retries failed, log the issue but don't crash
    debugPrint('Failed to load complete profile after $maxRetries attempts');
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
