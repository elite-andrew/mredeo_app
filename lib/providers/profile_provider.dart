import 'package:flutter/material.dart';
import 'package:redeo_app/data/services/profile_service.dart';
import 'package:redeo_app/data/models/user_model.dart';
import 'package:redeo_app/core/utils/app_logger.dart';
import 'package:redeo_app/core/utils/image_cache_manager.dart';
import 'package:redeo_app/providers/auth_provider.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  AuthProvider? _authProvider;

  bool _isLoading = false;
  String? _errorMessage;
  User? _user;
  UserSettings? _settings;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  UserSettings? get settings => _settings;

  // Set auth provider for cross-provider updates
  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;

    // Only sync immediately if we have no user data at all
    if (_user == null && _authProvider?.currentUser != null) {
      AppLogger.provider(
        'AuthProvider has user data but ProfileProvider doesn\'t, syncing immediately',
        'ProfileProvider',
      );
      syncWithAuthProvider();

      // Start loading full profile data from API
      loadProfile();
    }
  }

  // Sync with AuthProvider user data (fallback when API fails)
  void syncWithAuthProvider() {
    if (_authProvider?.currentUser != null) {
      final authUser = _authProvider!.currentUser!;

      // Only sync if we don't have user data, or preserve profile picture if we have it
      if (_user == null) {
        _user = authUser;
        AppLogger.provider(
          'Synced user data from AuthProvider (initial) - Profile picture: ${_user?.profilePicture}',
          'ProfileProvider',
        );
      } else {
        // Update user data but preserve profile picture if we have a better one
        final currentProfilePicture = _user!.profilePicture;
        _user = authUser.copyWith(
          profilePicture: currentProfilePicture ?? authUser.profilePicture,
        );
        AppLogger.provider(
          'Synced user data from AuthProvider (preserving profile picture) - Profile picture: ${_user?.profilePicture}',
          'ProfileProvider',
        );
      }

      notifyListeners();
    } else {
      AppLogger.warning(
        'AuthProvider currentUser is null during sync',
        'ProfileProvider',
      );
    }
  }

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
            'User data loaded successfully - Profile picture: ${_user?.profilePicture}',
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

        // Try fallback: sync with AuthProvider if available
        if (_authProvider?.currentUser != null) {
          AppLogger.provider(
            'API failed, falling back to AuthProvider data',
            'ProfileProvider',
          );
          syncWithAuthProvider();
          // Only clear error if we successfully got data from AuthProvider
          if (_user != null) {
            _clearError();
            AppLogger.provider(
              'Successfully recovered profile data from AuthProvider',
              'ProfileProvider',
            );
          } else {
            _setError(result['message'] ?? 'Failed to load profile');
          }
        } else {
          _setError(result['message'] ?? 'Failed to load profile');
        }
      }
    } catch (e) {
      AppLogger.error('Profile loading failed', 'ProfileProvider', e);

      // Try fallback: sync with AuthProvider if available
      if (_authProvider?.currentUser != null) {
        AppLogger.provider(
          'Exception occurred, falling back to AuthProvider data',
          'ProfileProvider',
        );
        syncWithAuthProvider();
        // Only clear error if we successfully got data from AuthProvider
        if (_user != null) {
          _clearError();
          AppLogger.provider(
            'Successfully recovered profile data from AuthProvider',
            'ProfileProvider',
          );
        } else {
          _setError('Failed to load profile: ${e.toString()}');
        }
      } else {
        _setError('Failed to load profile: ${e.toString()}');
      }
    }

    _setLoading(false);
  }

  // Force refresh profile data
  Future<void> refreshProfile() async {
    AppLogger.provider('Forcing profile refresh...', 'ProfileProvider');
    await loadProfile();
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

    try {
      final result = await _profileService.updateProfile(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
      );

      AppLogger.provider(
        'Profile service response: $result',
        'ProfileProvider',
      );

      if (result['success'] == true) {
        // Check if we have user data in the response
        // Backend returns: { success: true, data: { user: {...} }, message: "..." }
        // ProfileService wraps it as: { success: true, data: backendResponse, message: "..." }
        // So user data is at: result['data']['data']['user']
        if (result['data'] != null &&
            result['data']['data'] != null &&
            result['data']['data']['user'] != null) {
          _user = User.fromJson(result['data']['data']['user']);

          // Also update AuthProvider's currentUser if available
          if (_authProvider?.currentUser != null) {
            _authProvider!.updateCurrentUser(_user!);
          }
        } else {
          AppLogger.warning(
            'Profile update succeeded but no user data returned, refreshing profile...',
            'ProfileProvider',
          );
          // Refresh profile data from API
          await loadProfile();
        }

        AppLogger.provider('Profile updated successfully', 'ProfileProvider');
        _setLoading(false);
        notifyListeners(); // Ensure UI updates
        return {
          'success': true,
          'message': result['message'] ?? 'Profile updated successfully',
        };
      } else {
        AppLogger.warning(
          'Profile update failed: ${result['message']}',
          'ProfileProvider',
        );
        _setError(result['message'] ?? 'Failed to update profile');
        _setLoading(false);
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      AppLogger.error('Profile update error', 'ProfileProvider', e);
      _setError('Failed to update profile: ${e.toString()}');
      _setLoading(false);
      return {
        'success': false,
        'message': 'Failed to update profile: ${e.toString()}',
      };
    }
  }

  // Upload profile picture
  Future<Map<String, dynamic>> uploadProfilePicture(String imagePath) async {
    _setLoading(true);
    _clearError();

    AppLogger.info('Starting profile picture upload...', 'ProfileProvider');

    final result = await _profileService.uploadProfilePicture(imagePath);

    AppLogger.info('Upload result structure: $result', 'ProfileProvider');

    if (result['success']) {
      // Fix: Backend returns profile_picture_url directly in data
      final newProfilePictureUrl = result['data']['profile_picture_url'];

      AppLogger.info(
        'New profile picture URL from backend: $newProfilePictureUrl',
        'ProfileProvider',
      );

      // Clear cache for old profile picture URL if it exists
      if (_user?.profilePictureUrl != null) {
        try {
          await ImageCacheManager.clearImageCache(_user!.profilePictureUrl!);
          AppLogger.info(
            'Cleared old profile picture from cache: ${_user!.profilePictureUrl}',
            'ProfileProvider',
          );
        } catch (e) {
          AppLogger.warning(
            'Failed to clear old profile picture cache: $e',
            'ProfileProvider',
          );
        }
      }

      // Log current user state before update
      AppLogger.info(
        'Current user before update: ${_user?.profilePicture}',
        'ProfileProvider',
      );
      AppLogger.info(
        'AuthProvider user before update: ${_authProvider?.currentUser?.profilePicture}',
        'ProfileProvider',
      );

      // Update local user model
      _user = _user?.copyWith(profilePicture: newProfilePictureUrl);

      AppLogger.info(
        'ProfileProvider user after update: ${_user?.profilePicture}',
        'ProfileProvider',
      );
      AppLogger.info(
        'Profile picture URL constructed: ${_user?.profilePictureUrl}',
        'ProfileProvider',
      );

      // Also update AuthProvider's currentUser if available
      if (_authProvider?.currentUser != null) {
        _authProvider!.updateCurrentUser(
          _authProvider!.currentUser!.copyWith(
            profilePicture: newProfilePictureUrl,
          ),
        );
        AppLogger.info(
          'AuthProvider user after update: ${_authProvider?.currentUser?.profilePicture}',
          'ProfileProvider',
        );
        AppLogger.info(
          'AuthProvider profile picture URL: ${_authProvider?.currentUser?.profilePictureUrl}',
          'ProfileProvider',
        );
      } else {
        AppLogger.warning(
          'AuthProvider or currentUser is null, could not sync profile picture',
          'ProfileProvider',
        );
      }

      _setLoading(false);
      notifyListeners(); // Ensure UI updates

      AppLogger.provider(
        'Profile picture uploaded successfully - Final URL: ${_user?.profilePictureUrl}',
        'ProfileProvider',
      );
      return {'success': true, 'message': result['message']};
    } else {
      AppLogger.error(
        'Profile picture upload failed: ${result['message']}',
        'ProfileProvider',
      );
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

    AppLogger.info(
      'ProfileProvider: Starting password change',
      'ProfileProvider',
    );

    // Use AuthProvider's Firebase Auth method for password changes
    if (_authProvider != null) {
      final result = await _authProvider!.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _setLoading(false);
      if (result['success']) {
        AppLogger.info(
          'ProfileProvider: Password change successful',
          'ProfileProvider',
        );
        return {'success': true, 'message': result['message']};
      } else {
        AppLogger.warning(
          'ProfileProvider: Password change failed - ${result['message']}',
          'ProfileProvider',
        );
        _setError(result['message']);
        return {'success': false, 'message': result['message']};
      }
    } else {
      AppLogger.warning(
        'ProfileProvider: AuthProvider not available, using fallback',
        'ProfileProvider',
      );
      // Fallback to service method if AuthProvider is not available
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
