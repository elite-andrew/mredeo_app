import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redeo_app/config/app_routes.dart';
import 'package:redeo_app/core/theme/app_colors.dart';
import 'package:redeo_app/widgets/common/app_button.dart';
import 'package:redeo_app/widgets/common/app_text_field.dart';
import 'package:redeo_app/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _obscurePassword = true;
  String? _identifierError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _identifierController.addListener(_validateIdentifier);
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _identifierController.removeListener(_validateIdentifier);
    _passwordController.removeListener(_validatePassword);
    _identifierController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _validateIdentifier() {
    final input = _identifierController.text.trim();
    setState(() {
      if (input.isEmpty) {
        _identifierError = null;
      } else if (_isValidEmailOrPhone(input)) {
        _identifierError = null;
      } else {
        _identifierError = 'Please enter a valid email or phone number';
      }
    });
  }

  bool _isValidEmailOrPhone(String input) {
    // Check if it's a valid email
    bool isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input);

    // Check if it's a valid phone number (+255XXXXXXXXX or 0XXXXXXXXX)
    bool isPhone = RegExp(r'^(\+255\d{9}|0\d{9})$').hasMatch(input);

    return isEmail || isPhone;
  }

  void _validatePassword() {
    final input = _passwordController.text.trim();
    setState(() {
      if (input.isEmpty) {
        _passwordError = 'Password is required';
      } else if (input.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }
    });
  }

  Future<void> _handleSignIn() async {
    // Validate inputs first
    _validateIdentifier();
    _validatePassword();

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    // Check if inputs are valid
    if (identifier.isEmpty) {
      setState(() {
        _identifierError = 'Email or phone number is required';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
      return;
    }

    if (_identifierError != null || _passwordError != null) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final result = await authProvider.login(identifier, password);

      if (!mounted) return;

      if (result['success']) {
        if (result['requiresOtp']) {
          // Navigate to OTP screen
          context.push(
            AppRoutes.otpScreen,
            extra: {
              'phoneNumber': authProvider.phoneNumber,
              'purpose': 'login',
            },
          );
        } else {
          // Navigate to dashboard
          context.go(AppRoutes.dashboard);
        }
      } else if (result['requiresVerification'] == true) {
        // Account needs phone verification - show specific message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Please verify your phone number',
            ),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Sign Up',
              textColor: AppColors.surface,
              onPressed: () => context.push(AppRoutes.register),
            ),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Login failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final safePadding = MediaQuery.of(context).padding;
    final isKeyboardVisible = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: AppColors.surface,
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
                      backgroundColor: AppColors.primary,
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
                      'Please enter your email or phone and password.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Spacing
                    SizedBox(height: isKeyboardVisible ? 15 : 30),

                    // Form Fields
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Column(
                          children: [
                            AppTextField(
                              hintText: 'Email or Phone Number',
                              controller: _identifierController,
                              errorText: _identifierError,
                              onChanged: (_) => _validateIdentifier(),
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 23),

                            AppTextField(
                              hintText: 'Password',
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              errorText: _passwordError,
                              onChanged: (_) => _validatePassword(),
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
                                    authProvider.isLoading
                                        ? null
                                        : () {
                                          context.go(AppRoutes.forgotPassword);
                                        },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: AppColors.primary,
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
                              onPressed:
                                  authProvider.isLoading
                                      ? null
                                      : () {
                                        // Check validation before proceeding
                                        if (_identifierError != null ||
                                            _passwordError != null ||
                                            _identifierController.text
                                                .trim()
                                                .isEmpty ||
                                            _passwordController.text
                                                .trim()
                                                .isEmpty) {
                                          // Show validation message if inputs are incomplete
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Please complete all fields correctly',
                                              ),
                                              backgroundColor: AppColors.error,
                                            ),
                                          );
                                        } else {
                                          // All inputs are valid, proceed with sign in
                                          _handleSignIn();
                                        }
                                      },
                              text: 'Sign In',
                              isLoading: authProvider.isLoading,
                            ),

                            // Registration prompt - below sign in button
                            const SizedBox(height: 20),
                            Center(
                              child: GestureDetector(
                                onTap:
                                    authProvider.isLoading
                                        ? null
                                        : () {
                                          context.push(AppRoutes.register);
                                        },
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Don\'t have an account? ',
                                      ),
                                      TextSpan(
                                        text: 'Sign up',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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
