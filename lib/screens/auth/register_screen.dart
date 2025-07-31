import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redeo_app/config/app_routes.dart';
import 'package:redeo_app/widgets/common/app_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // Handle keyboard properly
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Avatar
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFF6A7180),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Title
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Join  MREDEO Pay',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Please enter your registration number and password.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Sign Up with Phone Number
                    AppButton(
                      onPressed: () {
                        // Navigate to phone sign up
                      },
                      text: 'Sign Up With Phone Number',
                    ),
                    const SizedBox(height: 16),

                    // Sign Up with Email
                    AppButton(
                      onPressed: () {
                        // Navigate to email sign up
                      },
                      text: 'Sign Up With  Email',
                    ),

                    const SizedBox(height: 16),

                    // Or
                    const Text(
                      'Or',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),

                    // Google Sign In - Multiple solutions provided
                    _buildGoogleSignInButton(),

                    // Flexible spacer that adapts to content
                    const Expanded(child: SizedBox()),

                    // Terms of Service
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text.rich(
                        TextSpan(
                          text: 'By joining, you agree to MREDEO Pay\'s ',
                          style: const TextStyle(fontSize: 13),
                          children: [
                            TextSpan(
                              text: 'Terms of Service',
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                              // You can add GestureRecognizer here for tap handling
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Sign In (bottom right)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          context.go(AppRoutes.login);
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16), // Add bottom padding
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    // Using asset with error handling - recommended approach
    return AppButton(
      onPressed: () {
        // Trigger Google sign-in
      },
      text: 'Continue With Google',
      icon: Image.asset(
        'assets/icons/google.png',
        height: 20,
        width: 20,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if image fails to load
          return Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: Colors.red.shade600,
            ),
            child: const Center(
              child: Text(
                'G',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
