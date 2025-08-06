class AppConfig {
  // API Configuration
  // Replace 192.168.1.100 with the actual IP address of your backend PC
  // Keep the port number that your backend is running on (5000, 3000, etc.)
  static const String baseUrl = 'http://192.168.5.45:3000/api/v1';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Performance optimizations
  static const Duration cacheTimeout = Duration(minutes: 5);
  static const Duration retryDelay = Duration(seconds: 2);
  static const int maxRetries = 3;
  static const int maxConcurrentRequests = 5;
  static const Duration connectivityCheckInterval = Duration(seconds: 5);

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';

  // App Constants
  static const String appName = 'MREDEO';
  static const String appVersion = '1.0.0';

  // Environment
  static const bool isProduction = false;
  static const bool enableLogging = true;

  // Performance settings
  static const bool enableCaching = true;
  static const bool enableCompression = true;
  static const bool enableRetryLogic = true;
  static const bool enableOfflineMode = true;

  // Image optimization
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const double imageCompressionQuality = 0.8;
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;

  // Pagination settings
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Animation settings for better performance
  static const Duration fastAnimationDuration = Duration(milliseconds: 200);
  static const Duration normalAnimationDuration = Duration(milliseconds: 300);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
}

// API Endpoints
class ApiEndpoints {
  // Authentication
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String verifyOTP = '/auth/verify-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';

  // Profile
  static const String profile = '/profile';
  static const String updateProfile = '/profile';
  static const String uploadProfilePicture = '/profile/picture';

  // Payments
  static const String payments = '/payments';
  static const String paymentHistory = '/payments/history';
  static const String paymentDetails = '/payments';
  static const String makePayment = '/payments';

  // Contributions
  static const String contributions = '/contributions';

  // Notifications
  static const String notifications = '/notifications';
  static const String markAsRead = '/notifications';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String issuePayment = '/payments/issue';
  static const String paymentsReport = '/payments/admin/report';
}

// Performance constants
class PerformanceConfig {
  // Cache keys
  static const String userProfileCache = 'user_profile_cache';
  static const String paymentsCache = 'payments_cache';
  static const String notificationsCache = 'notifications_cache';
  static const String contributionsCache = 'contributions_cache';

  // Cache durations
  static const Duration userProfileCacheDuration = Duration(minutes: 10);
  static const Duration paymentsCacheDuration = Duration(minutes: 5);
  static const Duration notificationsCacheDuration = Duration(minutes: 2);
  static const Duration contributionsCacheDuration = Duration(minutes: 15);

  // Request priorities
  static const int highPriority = 1;
  static const int normalPriority = 2;
  static const int lowPriority = 3;

  // Batch operation sizes
  static const int maxBatchSize = 50;
  static const int optimalBatchSize = 20;
}
