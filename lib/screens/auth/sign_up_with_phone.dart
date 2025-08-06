import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redeo_app/core/theme/app_colors.dart';
import 'package:redeo_app/config/app_routes.dart';
import 'package:redeo_app/widgets/common/app_button.dart';
import 'package:redeo_app/widgets/common/app_text_field.dart';
import 'package:redeo_app/providers/auth_provider.dart';

class SignUpWithPhoneScreen extends StatefulWidget {
  const SignUpWithPhoneScreen({super.key});

  @override
  State<SignUpWithPhoneScreen> createState() => _SignUpWithPhoneScreenState();
}

class _SignUpWithPhoneScreenState extends State<SignUpWithPhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _phoneError;
  String? _fullNameError;
  String? _usernameError;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhoneNumber);
    _fullNameController.addListener(_validateFullName);
    _usernameController.addListener(_validateUsername);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhoneNumber);
    _fullNameController.removeListener(_validateFullName);
    _usernameController.removeListener(_validateUsername);
    _phoneController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validatePhoneNumber() {
    final phoneNumber = _phoneController.text.trim();
    setState(() {
      _phoneError =
          phoneNumber.isEmpty
              ? null
              : _isPhoneNumberValid(phoneNumber)
              ? null
              : 'Phone number must be in format +255XXXXXXXXX or 0XXXXXXXXX';
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

  bool _isPhoneNumberValid(String phoneNumber) {
    // Validate +255 format followed by 9 digits
    bool isValidPlus255 = RegExp(r'^\+255\d{9}$').hasMatch(phoneNumber);

    // Validate 0 format followed by 9 digits
    bool isValidZero = RegExp(r'^0\d{9}$').hasMatch(phoneNumber);

    return isValidPlus255 || isValidZero;
  }

  // This function is no longer used, we now use _phoneError directly
  // String? _getPhoneErrorText() {
  //   // Only show error if the field is not empty and is invalid
  //   if (_phoneController.text.isNotEmpty &&
  //       !_isPhoneNumberValid(_phoneController.text)) {
  //     return 'Phone number must be in format +255XXXXXXXXX or 0XXXXXXXXX';
  //   }
  //   return null;
  // }

  void _handleSignUp() async {
    // Validate phone number
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your phone number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_isPhoneNumberValid(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number'),
          backgroundColor: AppColors.error,
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
          backgroundColor: AppColors.error,
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
          backgroundColor: AppColors.error,
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
          backgroundColor: AppColors.error,
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
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate password
    if (!_isPasswordValid(_passwordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid password'),
          backgroundColor: AppColors.error,
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
        phoneNumber: phoneNumber,
        password: _passwordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Account created successfully!',
              ),
              backgroundColor: const Color(0xFF2ECC71),
            ),
          );

          // Navigate to OTP verification or login
          context.go(AppRoutes.login);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Signup failed'),
              backgroundColor: AppColors.error,
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
            backgroundColor: AppColors.error,
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

                    // Phone Number Field
                    AppTextField(
                      hintText: 'Phone Number',
                      controller: _phoneController,
                      errorText: _phoneError,
                      keyboardType: TextInputType.phone,
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
