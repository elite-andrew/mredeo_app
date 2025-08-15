import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:redeo_app/widgets/common/custom_app_bar.dart';
import 'package:redeo_app/widgets/common/app_button.dart';
import 'package:redeo_app/widgets/common/validated_text_field.dart';
import 'package:redeo_app/core/theme/app_colors.dart';
import 'package:redeo_app/providers/profile_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    // Add listener to current password to trigger validation on new password field
    _currentPasswordController.addListener(() {
      if (_newPasswordController.text.isNotEmpty) {
        _formKey.currentState?.validate();
      }
    });
    // Add listener to new password to trigger validation on confirm password field
    _newPasswordController.addListener(() {
      if (_confirmPasswordController.text.isNotEmpty) {
        _formKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    final result = await profileProvider.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(); // Go back to profile screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (value == _currentPasswordController.text) {
      return 'New password must be different from current password';
    }
    // Additional password strength checks
    if (!value.contains(RegExp(r'[A-Za-z]'))) {
      return 'Password must contain at least one letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  Widget _buildRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: isValid ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isValid ? Colors.green : Colors.grey[600],
              fontWeight: isValid ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomAppBar(title: 'Change Password'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Change Your Password',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please enter your current password and choose a new one',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),

                          ValidatedTextField(
                            controller: _currentPasswordController,
                            label: 'Current Password',
                            hintText: 'Enter your current password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: !_showCurrentPassword,
                            onToggleVisibility: () {
                              setState(() {
                                _showCurrentPassword = !_showCurrentPassword;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your current password';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          ValidatedTextField(
                            controller: _newPasswordController,
                            label: 'New Password',
                            hintText: 'Enter your new password',
                            prefixIcon: Icons.lock,
                            obscureText: !_showNewPassword,
                            onToggleVisibility: () {
                              setState(() {
                                _showNewPassword = !_showNewPassword;
                              });
                            },
                            validator: _validateNewPassword,
                          ),

                          const SizedBox(height: 8),

                          // Password requirements helper
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Password Requirements:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildRequirement(
                                  'At least 6 characters',
                                  _newPasswordController.text.length >= 6,
                                ),
                                _buildRequirement(
                                  'Contains at least one letter',
                                  _newPasswordController.text.contains(
                                    RegExp(r'[A-Za-z]'),
                                  ),
                                ),
                                _buildRequirement(
                                  'Contains at least one number',
                                  _newPasswordController.text.contains(
                                    RegExp(r'[0-9]'),
                                  ),
                                ),
                                _buildRequirement(
                                  'Different from current password',
                                  _newPasswordController.text !=
                                          _currentPasswordController.text &&
                                      _newPasswordController.text.isNotEmpty,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          ValidatedTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm New Password',
                            hintText: 'Confirm your new password',
                            prefixIcon: Icons.lock,
                            obscureText: !_showConfirmPassword,
                            onToggleVisibility: () {
                              setState(() {
                                _showConfirmPassword = !_showConfirmPassword;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your new password';
                              }
                              if (value != _newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Consumer<ProfileProvider>(
                      builder: (context, profileProvider, child) {
                        return AppButton(
                          text: 'Change Password',
                          onPressed: _changePassword,
                          isLoading: profileProvider.isLoading,
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
