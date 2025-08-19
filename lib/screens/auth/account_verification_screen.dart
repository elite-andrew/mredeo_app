import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mredeo_app/config/app_routes.dart';
import 'package:mredeo_app/core/theme/app_colors.dart';
import 'package:mredeo_app/providers/auth_provider.dart';
import 'package:mredeo_app/widgets/common/app_button.dart';

class AccountVerificationScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? email;
  final String? fullName;
  final String verificationType; // 'phone' or 'email'
  final String? verificationId; // Firebase phone verification id
  final String? purpose; // 'login' or null (signup)

  const AccountVerificationScreen({
    super.key,
    this.phoneNumber,
    this.email,
    this.fullName,
    required this.verificationType,
    this.verificationId,
    this.purpose,
  });

  @override
  State<AccountVerificationScreen> createState() =>
      _AccountVerificationScreenState();
}

class _AccountVerificationScreenState extends State<AccountVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _currentVerificationId;
  int _resendSecondsRemaining = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    if (widget.verificationType == 'phone') {
      _startResendCountdown(seconds: 60);
    }
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCountdown({int seconds = 60}) {
    _resendTimer?.cancel();
    setState(() => _resendSecondsRemaining = seconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendSecondsRemaining <= 1) {
        timer.cancel();
        setState(() => _resendSecondsRemaining = 0);
      } else {
        setState(() => _resendSecondsRemaining -= 1);
      }
    });
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();
  bool get _isOtpComplete => _otpCode.length == 6;

  void _clearOtp() {
    for (final c in _otpControllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_isOtpComplete && !_isLoading) {
          _handleVerification();
        }
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  Future<void> _handleVerification() async {
    if (!_isOtpComplete) {
      setState(() => _errorMessage = 'Please enter the complete OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (widget.verificationType == 'phone') {
        final isLogin = (widget.purpose == 'login');
        final verificationId =
            _currentVerificationId ?? widget.verificationId ?? '';
        final fbRes =
            isLogin
                ? await authProvider.confirmPhoneLoginOtp(
                  verificationId: verificationId,
                  smsCode: _otpCode,
                )
                : await authProvider.confirmPhoneSignupOtp(
                  verificationId: verificationId,
                  smsCode: _otpCode,
                );
        if (!mounted) return;
        if (fbRes['success'] != true) {
          setState(() {
            _isLoading = false;
            _errorMessage = fbRes['message'] ?? 'Verification failed';
          });
          _clearOtp();
          return;
        }
        if (isLogin) {
          setState(() => _isLoading = false);
          context.go(AppRoutes.dashboard);
        } else {
          final backendRes = await authProvider.completePhoneSignup();
          if (!mounted) return;
          setState(() => _isLoading = false);
          if (backendRes['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Account verified successfully! You can now login.',
                ),
                backgroundColor: AppColors.primary,
                duration: Duration(seconds: 3),
              ),
            );
            context.go(AppRoutes.login);
          } else {
            setState(
              () =>
                  _errorMessage =
                      backendRes['message'] ?? 'Verification failed',
            );
            _clearOtp();
          }
        }
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Check your email for the verification link and then log in.',
            ),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 3),
          ),
        );
        context.go(AppRoutes.login);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An error occurred. Please try again.';
        });
        _clearOtp();
      }
    }
  }

  Future<void> _handleResendOtp() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      if (widget.verificationType == 'phone') {
        final authProvider = context.read<AuthProvider>();
        final res = await authProvider.resendPhoneOtp();
        if (!mounted) return;
        setState(() => _isResending = false);
        if (res['success'] == true) {
          final newId = res['verificationId'] as String?;
          if (newId != null) {
            setState(() => _currentVerificationId = newId);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP resent to your phone number'),
              backgroundColor: AppColors.primary,
              duration: Duration(seconds: 3),
            ),
          );
          _clearOtp();
          _startResendCountdown(seconds: 60);
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Failed to resend OTP'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }

      if (mounted) setState(() => _isResending = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResending = false;
          _errorMessage = 'Failed to resend OTP. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go(AppRoutes.register),
        ),
        centerTitle: true,
        title: const Text(
          'Verify Account',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Verify Your Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                widget.verificationType == 'email'
                    ? 'We sent a verification link to\n${widget.email}\nOpen the email and tap the link to continue.'
                    : 'We have sent a 6-digit verification code to\n${widget.phoneNumber}',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.fullName != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Hello ${widget.fullName}!',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    height: 60,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: const EdgeInsets.all(0),
                        filled: true,
                        fillColor: AppColors.surfaceInput,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                _errorMessage != null
                                    ? AppColors.error
                                    : AppColors.border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                _errorMessage != null
                                    ? AppColors.error
                                    : AppColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                _errorMessage != null
                                    ? AppColors.error
                                    : AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (v) => _onOtpChanged(v, index),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              AppButton(
                text: _isLoading ? 'Verifying...' : 'Verify Account',
                onPressed:
                    _isLoading || !_isOtpComplete ? null : _handleVerification,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Didn\'t receive the code? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap:
                        (_isResending || _resendSecondsRemaining > 0)
                            ? null
                            : _handleResendOtp,
                    child: Text(
                      _isResending
                          ? 'Resending...'
                          : (_resendSecondsRemaining > 0
                              ? 'Resend in ${_resendSecondsRemaining}s'
                              : 'Resend'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            (_isResending || _resendSecondsRemaining > 0)
                                ? AppColors.textSecondary
                                : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Why do I need to verify?',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.verificationType == 'email'
                          ? 'Account verification ensures the security of your MREDEO Pay account and confirms your email address for important notifications about your payments.'
                          : 'Account verification ensures the security of your MREDEO Pay account and enables you to receive important notifications about your payments.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
