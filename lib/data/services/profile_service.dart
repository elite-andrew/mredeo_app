import 'package:dio/dio.dart';
import 'package:redeo_app/config/app_config.dart';
import 'api_service.dart';

class ProfileService {
  final ApiService _apiService = ApiService();

  // Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiService.get(ApiEndpoints.profile);

      // Return the response data directly (it already has success/data structure)
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return _handleError(e);
    }
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (fullName != null) data['full_name'] = fullName;
      if (email != null) data['email'] = email;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;

      final response = await _apiService.put(
        ApiEndpoints.updateProfile,
        data: data,
      );

      return {
        'success': true,
        'data': response.data,
        'message': 'Profile updated successfully',
      };
    } catch (e) {
      return _handleError(e);
    }
  }

  // Upload profile picture
  Future<Map<String, dynamic>> uploadProfilePicture(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'picture': await MultipartFile.fromFile(imagePath),
      });

      final response = await _apiService.post(
        ApiEndpoints.uploadProfilePicture,
        data: formData,
      );

      return {
        'success': true,
        'data': response.data,
        'message': 'Profile picture updated successfully',
      };
    } catch (e) {
      return _handleError(e);
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.put(
        '${ApiEndpoints.profile}/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      return {
        'success': true,
        'data': response.data,
        'message': 'Password changed successfully',
      };
    } catch (e) {
      return _handleError(e);
    }
  }

  // Update settings
  Future<Map<String, dynamic>> updateSettings({
    String? language,
    bool? darkMode,
    bool? notificationsEnabled,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (language != null) data['language'] = language;
      if (darkMode != null) data['dark_mode'] = darkMode;
      if (notificationsEnabled != null) {
        data['notifications_enabled'] = notificationsEnabled;
      }

      final response = await _apiService.put(
        '${ApiEndpoints.profile}/settings',
        data: data,
      );

      return {
        'success': true,
        'data': response.data,
        'message': 'Settings updated successfully',
      };
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
