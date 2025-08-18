import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:redeo_app/providers/auth_provider.dart';
import 'package:redeo_app/core/utils/app_logger.dart';

class AuthGuard {
  static Widget buildGuardedWidget({
    required Widget child,
    required BuildContext context,
  }) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // If not logged in, redirect to login
        if (!authProvider.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If logged in, return the child widget
        return child;
      },
    );
  }

  /// Redirects user to appropriate dashboard based on their role
  static void redirectToDashboard(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn) {
      AppLogger.warning(
        'Attempted to redirect non-logged in user to dashboard',
        'AuthGuard',
      );
      context.go('/login');
      return;
    }

    final route = authProvider.dashboardRoute;
    AppLogger.info(
      'Redirecting user to dashboard: $route (role: ${authProvider.userRole})',
      'AuthGuard',
    );
    context.go(route);
  }

  /// Check if current user has admin privileges
  static bool isUserAdmin(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAdmin;
  }

  /// Guard for admin-only routes
  static Widget buildAdminGuard({
    required Widget child,
    required BuildContext context,
  }) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // If not logged in, redirect to login
        if (!authProvider.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If not admin, redirect to member dashboard
        if (!authProvider.isAdmin) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppLogger.warning(
              'Non-admin user attempted to access admin route',
              'AuthGuard',
            );
            context.go('/dashboard');
          });
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Access Denied',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Redirecting to dashboard...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        // If admin, return the child widget
        return child;
      },
    );
  }
}
