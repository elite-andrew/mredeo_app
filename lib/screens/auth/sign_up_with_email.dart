import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redeo_app/core/theme/app_colors.dart';
import 'package:redeo_app/config/app_routes.dart';
import 'package:redeo_app/widgets/common/app_button.dart';
import 'package:redeo_app/widgets/common/app_text_field.dart';

class SignUpWithEmailScreen extends StatefulWidget {
  const SignUpWithEmailScreen({super.key});

  @override
  State<SignUpWithEmailScreen> createState() => _SignUpWithEmailScreenState();
}

class _SignUpWithEmailScreenState extends State<SignUpWithEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _usernameError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _usernameController.addListener(_validateUsername);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _usernameController.removeListener(_validateUsername);
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    setState(() {
      if (email.isEmpty) {
        _emailError = null;
      } else if (_isEmailValid(email)) {
        _emailError = null;
      } else {
        _emailError = 'Please enter a valid email address';
      }
    });
  }

  void _validateUsername() {
    final username = _usernameController.text.trim();
    setState(() {
      if (username.isEmpty) {
        _usernameError = null;
      } else if (_isUsernameValid(username)) {
        _usernameError = null;
      } else {
        _usernameError =
            'Username can only contain letters, spaces, underscores, apostrophes, and periods';
      }
    });
  }

  bool _isUsernameValid(String username) {
    // Username can contain only letters, spaces, underscores, apostrophes, and periods (no numbers)
    return RegExp(r"^[a-zA-Z_. ']+$").hasMatch(username);
  }

  bool _isPasswordValid(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  void _handleSignUp() async {
    // Validate email
    final email = _emailController.text.trim();
    if (!_isEmailValid(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate username
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a username'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isUsernameValid(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Username can only contain letters, spaces, underscores, apostrophes, and periods',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate password
    if (!_isPasswordValid(_passwordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password does not meet requirements'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // For now, just show success message and navigate to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully! Please check your email for verification.',
          ),
          backgroundColor: AppColors.primary,
        ),
      );

      // Navigate to login screen
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      resizeToAvoidBottomInset: false,
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
                padding: EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: isKeyboardVisible ? 16.0 : 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    SizedBox(height: isKeyboardVisible ? 20 : 40),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 24,
                      ),
                      onPressed: () => context.pop(),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),

                    // Form fields section
                    SizedBox(height: isKeyboardVisible ? 20 : 40),

                    // Email Field
                    AppTextField(
                      hintText: 'Email Address',
                      controller: _emailController,
                      errorText: _emailError,
                      onChanged: (_) => _validateEmail(),
                      keyboardType: TextInputType.emailAddress,
                    ),

                    // Email hint
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, top: 8.0),
                      child: Text(
                        '- We\'ll send a verification link to this email.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Username Field
                    AppTextField(
                      hintText: 'Public username',
                      controller: _usernameController,
                      errorText: _usernameError,
                      onChanged: (_) => _validateUsername(),
                    ),

                    // Username hint
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '- You can\'t change your username so choose wisely.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '- Only letters, spaces, underscores (_), apostrophes (\'), and periods (.) allowed.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Password Field
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

                    // Password requirements
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, top: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '- At least 8 characters',
                            style: TextStyle(color: Colors.black, fontSize: 13),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '- At least 1 uppercase letter',
                            style: TextStyle(color: Colors.black, fontSize: 13),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '- At least 1 lowercase letter',
                            style: TextStyle(color: Colors.black, fontSize: 13),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '- At least 1 special character.',
                            style: TextStyle(color: Colors.black, fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    // Sign Up Button - positioned closer to form fields
                    SizedBox(height: isKeyboardVisible ? 30 : 60),
                    AppButton(
                      text: 'Sign Up',
                      onPressed: _isLoading ? () {} : _handleSignUp,
                      isLoading: _isLoading,
                    ),

                    // Bottom spacing
                    const Expanded(child: SizedBox()),
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
