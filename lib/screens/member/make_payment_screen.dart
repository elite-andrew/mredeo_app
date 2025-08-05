import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redeo_app/config/app_routes.dart';
import 'package:redeo_app/core/theme/app_colors.dart';
import 'package:redeo_app/widgets/common/custom_app_bar.dart';
import 'package:redeo_app/widgets/common/app_button.dart';
import 'package:redeo_app/widgets/common/app_text_field.dart';
import 'package:redeo_app/widgets/common/app_dropdown.dart';
import 'package:redeo_app/widgets/common/app_payment_dropdown.dart';

class MakePaymentScreen extends StatefulWidget {
  const MakePaymentScreen({super.key});

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedContributionType;
  String? _selectedPaymentService;
  bool _isLoading = false;
  String? _phoneError;

  final List<String> _contributionTypes = ['Yearly', 'Condolences', 'Sickness'];

  final List<PaymentItem> _paymentServices = [
    PaymentItem(name: 'T-pesa', iconPath: 'assets/icons/payment/tpesa.png'),
    PaymentItem(
      name: 'Halopesa',
      iconPath: 'assets/icons/payment/halopesa.png',
    ),
    PaymentItem(name: 'Mixx by Yas', iconPath: 'assets/icons/payment/mixx.png'),
    PaymentItem(name: 'M-Pesa', iconPath: 'assets/icons/payment/mpesa.png'),
    PaymentItem(
      name: 'AirtelMoney',
      iconPath: 'assets/icons/payment/airtel.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhoneNumber);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhoneNumber);
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhoneNumber() {
    final phoneNumber = _phoneController.text.trim();
    setState(() {
      if (phoneNumber.isEmpty) {
        _phoneError = null;
      } else if (_isPhoneNumberValid(phoneNumber)) {
        _phoneError = null;
      } else {
        _phoneError = '+255XXXXXXXXX or 0XXXXXXXXX';
      }
    });
  }

  bool _isPhoneNumberValid(String phoneNumber) {
    // Validate +255 format followed by 9 digits
    bool isValidPlus255 = RegExp(r'^\+255\d{9}$').hasMatch(phoneNumber);

    // Validate 0 format followed by 9 digits
    bool isValidZero = RegExp(r'^0\d{9}$').hasMatch(phoneNumber);

    return isValidPlus255 || isValidZero;
  }

  void _handleConfirmPayment() async {
    // Validation
    if (_selectedContributionType == null) {
      _showSnackBar('Please select a contribution type');
      return;
    }

    if (_amountController.text.trim().isEmpty) {
      _showSnackBar('Please enter an amount');
      return;
    }

    // Validate phone number
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      _showSnackBar('Please enter a phone number');
      return;
    }

    if (!_isPhoneNumberValid(phoneNumber)) {
      _showSnackBar('Please enter a valid phone number');
      return;
    }

    if (_selectedPaymentService == null) {
      _showSnackBar('Please select a payment service');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Navigate to payment status screen
      context.push(AppRoutes.paymentStatus);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomAppBar(title: 'Contribution Payment'),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Instructions text
                  const Text(
                    'Fill the details to complete your payment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Contribution Type Dropdown
                  AppDropdown(
                    label: 'Select Contribution Type',
                    value: _selectedContributionType,
                    hint: 'Select',
                    items: _contributionTypes,
                    onChanged: (value) {
                      setState(() {
                        _selectedContributionType = value;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Amount Field
                  AppTextField(
                    label: 'Enter Amount',
                    hintText: 'Amount',
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 24),

                  // Phone Number Field
                  AppTextField(
                    label: 'Payment number',
                    hintText: '+255XXXXXXXXX or 0XXXXXXXXX',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    errorText: _phoneError,
                    onChanged: (_) => _validatePhoneNumber(),
                  ),

                  const SizedBox(height: 24),

                  // Payment Service Dropdown
                  AppPaymentDropdown(
                    label: 'Select Payment Service',
                    value: _selectedPaymentService,
                    hint: 'Choose',
                    items: _paymentServices,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentService = value;
                      });
                    },
                  ),

                  const SizedBox(height: 60),

                  // Confirm Payment Button
                  AppButton(
                    text: 'Confirm Payment',
                    onPressed:
                        _isLoading
                            ? null // Keep disabled during loading state
                            : () {
                              // Check validation before proceeding
                              if (_phoneError != null ||
                                  _selectedContributionType == null ||
                                  _amountController.text.trim().isEmpty ||
                                  _phoneController.text.trim().isEmpty ||
                                  _selectedPaymentService == null) {
                                // Show validation message if inputs are incomplete
                                _showSnackBar(
                                  'Please complete all required fields correctly',
                                );
                              } else {
                                // All inputs are valid, proceed with payment
                                _handleConfirmPayment();
                              }
                            },
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
