import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:redeo_app/config/app_config.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Register new user
  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String username,
    required String phoneNumber,
    required String password,
    String? email,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.signup,
        data: {
          'full_name': fullName,
          'username': username,
          'phone_number': phoneNumber,
          'password': password,
          if (email != null) 'email': email,
        },
      );

      return {
        'success': true,
        'data': response.data,
        'message': 'Registration successful. Please verify your phone number.',
      };
    } catch (e) {
      return _handleError(e);
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
    required String purpose,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.verifyOTP,
        data: {
          'phone_number': phoneNumber,
          'otp_code': otpCode,
          'purpose': purpose,
        },
      );

      // If login OTP or signup OTP, store tokens if provided
      if (response.data['data']?['tokens'] != null) {
        await _storeTokens(response.data['data']['tokens']);
        if (response.data['data']['user'] != null) {
          await _storeUserData(response.data['data']['user']);
        }
      }

      return {
        'success': true,
        'data': response.data,
        'message': 'OTP verified successfully',
      };
    } catch (e) {
      return _handleError(e);
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
      );

      if (response.data['data']?['requires_otp'] == true) {
        return {
          'success': true,
          'requiresOtp': true,
          'message': 'OTP sent to your phone number',
          'phoneNumber': response.data['data']['phone_number'],
        };
      } else if (response.data['data']?['tokens'] != null) {
        await _storeTokens(response.data['data']['tokens']);
        if (response.data['data']['user'] != null) {
          await _storeUserData(response.data['data']['user']);
        }
        return {
          'success': true,
          'data': response.data,
          'message': 'Login successful',
        };
      }

      return {'success': false, 'message': 'Login failed'};
    } catch (e) {
      return _handleError(e);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.post(ApiEndpoints.logout);
    } catch (e) {
      developer.log('Logout error: $e', name: 'AuthService');
    } finally {
      await _clearTokens();
    }
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword({
    required String phoneNumber,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.forgotPassword,
        data: {'phone_number': phoneNumber},
      );

      return {
        'success': true,
        'data': response.data,
        'message': 'Password reset OTP sent to your phone',
      };
    } catch (e) {
      return _handleError(e);
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword({
    required String phoneNumber,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.resetPassword,
        data: {
          'phone_number': phoneNumber,
          'otp_code': otpCode,
          'new_password': newPassword,
        },
      );

      return {
        'success': true,
        'data': response.data,
        'message': 'Password reset successfully',
      };
    } catch (e) {
      return _handleError(e);
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final accessToken = await _storage.read(key: AppConfig.accessTokenKey);
    return accessToken != null;
  }

  // Get current user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _apiService.get(ApiEndpoints.profile);
      return response.data;
    } catch (e) {
      developer.log('Get current user error: $e', name: 'AuthService');
      return null;
    }
  }

  // Store tokens securely
  Future<void> _storeTokens(Map<String, dynamic> tokens) async {
    await _storage.write(
      key: AppConfig.accessTokenKey,
      value: tokens['access_token'],
    );
    await _storage.write(
      key: AppConfig.refreshTokenKey,
      value: tokens['refresh_token'],
    );
    await _storage.write(key: AppConfig.isLoggedInKey, value: 'true');
  }

  // Store user data
  Future<void> _storeUserData(Map<String, dynamic> userData) async {
    await _storage.write(
      key: AppConfig.userDataKey,
      value: userData.toString(),
    );
  }

  // Clear tokens
  Future<void> _clearTokens() async {
    await _storage.deleteAll();
  }

  // Handle API errors
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
