
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redeo_app/config/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate loading time then navigate
    Future.delayed(const Duration(seconds: 3), () {
      context.go(AppRoutes.login); // Change this to your desired route
    });
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
                // If you want an image in the circle:
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

