import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _lastActiveKey = 'last_active_timestamp';
  static const String _sessionTimeoutKey = 'session_timeout_minutes';
  static const String _firstLaunchKey = 'is_first_launch';

  // Session timeout in minutes (adjust as needed)
  static const int defaultSessionTimeoutMinutes = 5;

  /// Check if this is the first time launching the app
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstLaunchKey) ?? true;
  }

  /// Mark that the app has been launched
  static Future<void> markFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, false);
  }

  /// Update the last active timestamp
  static Future<void> updateLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_lastActiveKey, now);
  }

  /// Check if the session has expired
  static Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActive = prefs.getInt(_lastActiveKey);

    if (lastActive == null) {
      return true; // No previous session
    }

    final sessionTimeout =
        prefs.getInt(_sessionTimeoutKey) ?? defaultSessionTimeoutMinutes;
    final lastActiveTime = DateTime.fromMillisecondsSinceEpoch(lastActive);
    final now = DateTime.now();
    final difference = now.difference(lastActiveTime);

    return difference.inMinutes > sessionTimeout;
  }

  /// Set custom session timeout
  static Future<void> setSessionTimeout(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionTimeoutKey, minutes);
  }

  /// Clear all session data (for logout)
  static Future<void> clearSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastActiveKey);
    // Note: We don't remove _firstLaunchKey on logout
  }

  /// Get session timeout value
  static Future<int> getSessionTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_sessionTimeoutKey) ?? defaultSessionTimeoutMinutes;
  }
}
