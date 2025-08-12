import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redeo_app/core/theme/app_colors.dart';
import 'package:redeo_app/config/app_routes.dart';
import 'package:redeo_app/widgets/common/app_button.dart';
import 'package:redeo_app/widgets/common/app_text_field.dart';
import 'package:redeo_app/providers/auth_provider.dart';

class SignUpWithEmailScreen extends StatefulWidget {
  const SignUpWithEmailScreen({super.key});

  @override
  State<SignUpWithEmailScreen> createState() => _SignUpWithEmailScreenState();
}

class _SignUpWithEmailScreenState extends State<SignUpWithEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _fullNameError;
  String? _usernameError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _fullNameController.addListener(_validateFullName);
    _usernameController.addListener(_validateUsername);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _fullNameController.removeListener(_validateFullName);
    _usernameController.removeListener(_validateUsername);
    _emailController.dispose();
    _fullNameController.dispose();
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
            'Username must be 3-50 characters with letters, numbers, and underscores only';
      }
    });
  }

  void _validateFullName() {
    final fullName = _fullNameController.text.trim();
    setState(() {
      if (fullName.isEmpty) {
        _fullNameError = null;
      } else if (_isFullNameValid(fullName)) {
        _fullNameError = null;
      } else {
        _fullNameError =
            'Full name must be 2-100 characters with letters, spaces, apostrophes, and periods only';
      }
    });
  }

  bool _isFullNameValid(String fullName) {
    // Full name must be 2-100 characters (backend requirement)
    if (fullName.length < 2 || fullName.length > 100) return false;
    // Full name can contain only letters, spaces, apostrophes, and periods
    return RegExp(r"^[a-zA-Z. ']+$").hasMatch(fullName);
  }

  bool _isUsernameValid(String username) {
    // Username must be 3-50 alphanumeric characters (letters and numbers)
    // Backend expects alphanumeric, not just letters
    if (username.length < 3 || username.length > 50) return false;
    return RegExp(r"^[a-zA-Z0-9_]+$").hasMatch(username);
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

    // Validate full name
    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isFullNameValid(fullName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Full name must be 2-100 characters with letters, spaces, apostrophes, and periods only',
          ),
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
            'Username must be 3-50 characters with letters, numbers, and underscores only',
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

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.signup(
        fullName: fullName,
        username: username,
        phoneNumber: null, // Email signup doesn't require phone
        password: _passwordController.text,
        email: email,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ??
                    'Account created. Check your email for a verification link/code, then log in.',
              ),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 4),
            ),
          );

          // Navigate to login after email sign-up
          context.go(AppRoutes.login);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Signup failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

                    // Full Name Field
                    AppTextField(
                      hintText: 'Full Name',
                      controller: _fullNameController,
                      errorText: _fullNameError,
                      onChanged: (_) => _validateFullName(),
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
                            '- Username must be 3-50 characters with letters, numbers, and underscores (_) only.',
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
