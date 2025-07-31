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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
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
              minHeight: isKeyboardVisible
                  ? screenHeight - keyboardHeight - safePadding.top - safePadding.bottom - 20
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please enter your registration number and password.',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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

                    // Spacing before button
                    SizedBox(height: isKeyboardVisible ? 20 : 60),

                    // Sign In Button
                    AppButton(
                      onPressed: () {
                        // You might want to add form validation here
                        context.go(AppRoutes.dashboard);
                      },
                      text: 'Sign In',
                    ),

                    // Adaptive spacing
                    const Expanded(child: SizedBox()),

                    // Bottom Links - always show but with different styling
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            context.push(AppRoutes.register);
                          },
                          child: Text(
                            'Join',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: isKeyboardVisible ? 12 : 14,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go(AppRoutes.forgotPassword);
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: isKeyboardVisible ? 12 : 14,
                            ),
                          ),
                        ),
                      ],
                    ),
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