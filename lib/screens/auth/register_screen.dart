import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mredeo_app/config/app_routes.dart';
import 'package:mredeo_app/core/theme/app_colors.dart';
import 'package:mredeo_app/widgets/common/app_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      resizeToAvoidBottomInset: true,
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
                        backgroundColor: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Title
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Join MREDEO Pay',
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
                        context.push(AppRoutes.signUpWithPhone);
                      },
                      text: 'Sign Up With Phone Number',
                    ),
                    const SizedBox(height: 16),

                    // Sign Up with Email
                    AppButton(
                      onPressed: () {
                        context.push(AppRoutes.signUpWithEmail);
                      },
                      text: 'Sign Up With Email',
                    ),

                    const SizedBox(height: 16),

                    // Or
                    const Text(
                      'Or',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),

                    // Google Sign In
                    _buildGoogleSignInButton(),

                    const SizedBox(height: 24),

                    // Terms of Service - placed near signup actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          context.push(AppRoutes.termsAndConditions);
                        },
                        child: Text.rich(
                          TextSpan(
                            text: 'By joining, you agree to MREDEO Pay\'s ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms of Service',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    // Bottom spacing
                    const SizedBox(height: 40),
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
    return AppButton(
      onPressed: () {
        // Add Google sign-in logic here
      },
      text: 'Continue With Google',
      icon: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
        child: Image.asset(
          'assets/icons/google.png',
          width: 20,
          height: 20,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Enhanced fallback with better Google-like styling
            return Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4285F4), // Google blue
                    Color(0xFF34A853), // Google green
                    Color(0xFFFBBC05), // Google yellow
                    Color(0xFFEA4335), // Google red
                  ],
                  stops: [0.0, 0.33, 0.66, 1.0],
                ),
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
      ),
    );
  }
}
