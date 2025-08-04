import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redeo_app/config/app_routes.dart';
import 'package:redeo_app/widgets/common/app_button.dart';
import 'package:redeo_app/widgets/common/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _obscurePassword = true;
  // ignore: prefer_final_fields
  bool _isLoading = false; // Add loading state

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Handle sign in - bypass authentication for development
  Future<void> _handleSignIn() async {
    // Bypass authentication and go directly to dashboard
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final safePadding = MediaQuery.of(context).padding;
    final isKeyboardVisible = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, // Important: prevents automatic resizing
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  isKeyboardVisible
                      ? screenHeight -
                          keyboardHeight -
                          safePadding.top -
                          safePadding.bottom -
                          20
                      : screenHeight - safePadding.top - safePadding.bottom,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: isKeyboardVisible ? 16.0 : 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flexible top spacing
                    SizedBox(height: isKeyboardVisible ? 20 : 60),

                    // Circle Avatar (Left aligned)
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF6A7180),
                    ),

                    // Spacing
                    SizedBox(height: isKeyboardVisible ? 15 : 30),

                    // Welcome Text
                    const Text(
                      'Welcome to  MREDEO Pay',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please enter your registration number and password.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Spacing
                    SizedBox(height: isKeyboardVisible ? 15 : 30),

                    // Form Fields
                    AppTextField(
                      hintText: 'Email or Phone Number',
                      controller: _emailController,
                    ),

                    const SizedBox(height: 23),

                    AppTextField(
                      hintText: 'Password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),

                    // Forgot Password Link - positioned under password field
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () {
                                  context.go(AppRoutes.forgotPassword);
                                },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Color(0xFF2ECC71),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    // Spacing before button
                    SizedBox(height: isKeyboardVisible ? 20 : 60),

                    // Sign In Button
                    AppButton(
                      onPressed: _isLoading ? () {} : () => _handleSignIn(),
                      text: 'Sign In',
                      isLoading: _isLoading,
                    ),

                    // Registration prompt - below sign in button
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap:
                            _isLoading
                                ? null
                                : () {
                                  context.push(AppRoutes.register);
                                },
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            children: [
                              const TextSpan(text: 'Don\'t have an account? '),
                              TextSpan(
                                text: 'Sign up',
                                style: const TextStyle(
                                  color: Color(0xFF2ECC71),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Adaptive spacing
                    const Expanded(child: SizedBox()),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
