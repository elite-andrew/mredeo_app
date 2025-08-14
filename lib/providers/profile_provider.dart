import 'package:flutter/material.dart';
import 'package:redeo_app/data/services/profile_service.dart';
import 'package:redeo_app/data/models/user_model.dart';
import 'package:redeo_app/core/utils/app_logger.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  bool _isLoading = false;
  String? _errorMessage;
  User? _user;
  UserSettings? _settings;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  UserSettings? get settings => _settings;

  // Load user profile
  Future<void> loadProfile() async {
    AppLogger.provider('Loading user profile...', 'ProfileProvider');
    _setLoading(true);
    _clearError();

    try {
      final result = await _profileService.getProfile();
      AppLogger.provider('Profile API response received', 'ProfileProvider');

      if (result['success'] == true && result['data'] != null) {
        if (result['data']['user'] != null) {
          _user = User.fromJson(result['data']['user']);
          AppLogger.provider(
            'User data loaded successfully',
            'ProfileProvider',
          );
        }
        if (result['data']['settings'] != null) {
          _settings = UserSettings.fromJson(result['data']['settings']);
          AppLogger.provider(
            'User settings loaded successfully',
            'ProfileProvider',
          );
        }
      } else {
        AppLogger.warning(
          'Profile loading failed: ${result['message']}',
          'ProfileProvider',
        );
        _setError(result['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      AppLogger.error('Profile loading failed', 'ProfileProvider', e);
      _setError('Failed to load profile: ${e.toString()}');
    }

    _setLoading(false);
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
  }) async {
    AppLogger.provider('Updating user profile...', 'ProfileProvider');
    _setLoading(true);
    _clearError();

    final result = await _profileService.updateProfile(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
    );

    if (result['success']) {
      _user = User.fromJson(result['data']['user']);
      AppLogger.provider('Profile updated successfully', 'ProfileProvider');
      _setLoading(false);
      return {'success': true, 'message': result['message']};
    } else {
      AppLogger.warning(
        'Profile update failed: ${result['message']}',
        'ProfileProvider',
      );
      _setError(result['message']);
      _setLoading(false);
      return {'success': false, 'message': result['message']};
    }
  }

  // Upload profile picture
  Future<Map<String, dynamic>> uploadProfilePicture(String imagePath) async {
    _setLoading(true);
    _clearError();

    final result = await _profileService.uploadProfilePicture(imagePath);

    if (result['success']) {
      _user = _user?.copyWith(
        profilePicture: result['data']['profile_picture_url'],
      );
      _setLoading(false);
      return {'success': true, 'message': result['message']};
    } else {
      _setError(result['message']);
      _setLoading(false);
      return {'success': false, 'message': result['message']};
    }
  }

  // Update settings
  Future<Map<String, dynamic>> updateSettings({
    String? language,
    bool? darkMode,
    bool? notificationsEnabled,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _profileService.updateSettings(
      language: language,
      darkMode: darkMode,
      notificationsEnabled: notificationsEnabled,
    );

    if (result['success']) {
      _settings = UserSettings.fromJson(result['data']['settings']);
      _setLoading(false);
      return {'success': true, 'message': result['message']};
    } else {
      _setError(result['message']);
      _setLoading(false);
      return {'success': false, 'message': result['message']};
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _profileService.changePassword(
      currentPassword: currentPassword,
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

  // Clear profile data (for logout)
  void clearProfile() {
    _user = null;
    _settings = null;
    _clearError();
    notifyListeners();
  }
}
