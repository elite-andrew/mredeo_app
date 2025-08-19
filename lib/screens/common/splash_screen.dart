import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mredeo_app/config/app_routes.dart';
import 'package:mredeo_app/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Defer initialization to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    // Initialize authentication
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initializeAuth();

    // Wait minimum splash time
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      // Navigate based on auth state and user role
      if (authProvider.isLoggedIn) {
        final dashboardRoute = authProvider.dashboardRoute;
        context.go(dashboardRoute);
      } else {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF6A7180), // Your grey circle
                ),
                // To add an image, uncomment:
                // child: Image.asset('assets/logo.png'),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Your Payments, Your Union.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontStyle: FontStyle.italic,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    offset: Offset(2, 2),
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
