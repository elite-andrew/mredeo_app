class AppConfig {
  // API Configuration
  // Replace 192.168.1.100 with the actual IP address of your backend PC
  // Keep the port number that your backend is running on (5000, 3000, etc.)
  static const String baseUrl = 'http://192.168.1.100:5000/api/v1';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);

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
