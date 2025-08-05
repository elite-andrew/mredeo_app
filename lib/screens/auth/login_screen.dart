import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redeo_app/config/app_routes.dart';
import 'package:redeo_app/core/theme/app_colors.dart';
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
  String? _emailPhoneError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmailPhone);
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmailPhone);
    _passwordController.removeListener(_validatePassword);
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
  }

  bool _isValidPhoneNumber(String value) {
    // Validate +255 format followed by 9 digits
    bool isValidPlus255 = RegExp(r'^\+255\d{9}$').hasMatch(value);

    // Validate 0 format followed by 9 digits
    bool isValidZero = RegExp(r'^0\d{9}$').hasMatch(value);

    return isValidPlus255 || isValidZero;
  }

  void _validateEmailPhone() {
    final input = _emailController.text.trim();
    setState(() {
      if (input.isEmpty) {
        _emailPhoneError = null;
      } else if (_isValidEmail(input) || _isValidPhoneNumber(input)) {
        _emailPhoneError = null;
      } else {
        _emailPhoneError = 'Please enter a valid email or phone number';
      }
    });
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

  // Handle sign in - bypass authentication for development
  Future<void> _handleSignIn() async {
    // Validate inputs first
    _validateEmailPhone();
    _validatePassword();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Check if inputs are valid
    if (email.isEmpty) {
      setState(() {
        _emailPhoneError = 'Email or phone number is required';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
      return;
    }

    if (_emailPhoneError != null || _passwordError != null) {
      // Don't proceed if there are validation errors
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      // Bypass authentication and go directly to dashboard
      if (mounted) {
        context.go(AppRoutes.dashboard);
      }
    } catch (e) {
      // Handle any errors
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
                      errorText: _emailPhoneError,
                      onChanged: (_) => _validateEmailPhone(),
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
                            _isLoading
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
                          _isLoading
                              ? null // Keep disabled during loading state
                              : () {
                                // Check validation before proceeding
                                if (_emailPhoneError != null ||
                                    _passwordError != null ||
                                    _emailController.text.trim().isEmpty ||
                                    _passwordController.text.trim().isEmpty) {
                                  // Show validation message if inputs are incomplete
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            children: [
                              const TextSpan(text: 'Don\'t have an account? '),
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
