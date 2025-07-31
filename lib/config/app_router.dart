import 'package:go_router/go_router.dart';

import 'package:redeo_app/screens/admin/admin_dashboard_screen.dart';
import 'package:redeo_app/screens/admin/admin_profile_screen.dart';
import 'package:redeo_app/screens/admin/issue_notification_screen.dart';
import 'package:redeo_app/screens/admin/issue_payment_screen.dart';
import 'package:redeo_app/screens/admin/payment_report_screen.dart';
import 'package:redeo_app/screens/auth/forgot_password_screen.dart';


import 'package:redeo_app/screens/auth/login_screen.dart';
import 'package:redeo_app/screens/auth/otp_screen.dart';
import 'package:redeo_app/screens/auth/register_screen.dart';
import 'package:redeo_app/screens/auth/reset_password_screen.dart';
import 'package:redeo_app/screens/common/splash_screen.dart';
import 'package:redeo_app/screens/member/dashboard_screen.dart';
import 'package:redeo_app/screens/member/loading_payment_screen.dart';
import 'package:redeo_app/screens/member/make_payment_screen.dart';
import 'package:redeo_app/screens/member/member_profile_screen.dart';
import 'package:redeo_app/screens/member/notifications_screen.dart';
import 'package:redeo_app/screens/member/payment_status_screen.dart';
import 'package:redeo_app/screens/member/settings_screen.dart';
import 'package:redeo_app/screens/member/terms_and_conditions_screen.dart';
import 'package:redeo_app/screens/member/transactions_history_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    //Authentication Routes
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/forgot_password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/otp_screen',
      builder: (context, state) => const OtpScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/reset_password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),

    //Member Screens Routes
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/loading_payment',
      builder: (context, state) => const LoadingPaymentScreen(),
    ),
    GoRoute(
      path: '/make_payment',
      builder: (context, state) => const MakePaymentScreen(),
    ),
    GoRoute(
      path: '/member_profile',
      builder: (context, state) => const MemberProfileScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/payment_status',
      builder: (context, state) => const PaymentStatusScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/terms_and_conditions',
      builder: (context, state) => const TermsAndConditionsScreen(),
    ),
    GoRoute(
      path: '/transaction',
      builder: (context, state) => const TransactionsHistoryScreen(),
    ),

    //Administrator Screens Routes
    GoRoute(
      path: '/admin_dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin_profile',
      builder: (context, state) => const AdminProfileScreen(),
    ),
    GoRoute(
      path: '/issue_notification',
      builder: (context, state) => const IssueNotificationScreen(),
    ),
    GoRoute(
      path: '/issue_payment',
      builder: (context, state) => const IssuePaymentScreen(),
    ),
    GoRoute(
      path: '/payment_report',
      builder: (context, state) => const PaymentReportScreen(),
    )
  ],
);