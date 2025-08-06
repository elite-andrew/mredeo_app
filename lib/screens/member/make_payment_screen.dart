import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:redeo_app/config/app_routes.dart';
import 'package:redeo_app/core/theme/app_colors.dart';
import 'package:redeo_app/widgets/common/custom_app_bar.dart';
import 'package:redeo_app/widgets/common/app_button.dart';
import 'package:redeo_app/widgets/common/app_text_field.dart';
import 'package:redeo_app/widgets/common/app_payment_dropdown.dart';
import 'package:redeo_app/providers/payment_provider.dart';
import 'package:redeo_app/data/models/payment_model.dart';

class MakePaymentScreen extends StatefulWidget {
  const MakePaymentScreen({super.key});

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedContributionTypeId;
  String? _selectedPaymentService;
  bool _isLoading = false;
  String? _phoneError;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContributionTypes();
    });
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhoneNumber);
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadContributionTypes() async {
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );
    await paymentProvider.loadContributionTypes();
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

  TelcoProvider _getTelcoFromService(String serviceName) {
    switch (serviceName.toLowerCase()) {
      case 'm-pesa':
        return TelcoProvider.vodacom;
      case 't-pesa':
        return TelcoProvider.tigo;
      case 'halopesa':
        return TelcoProvider.halotel;
      case 'airtelmoney':
        return TelcoProvider.airtel;
      default:
        return TelcoProvider.other;
    }
  }

  void _handleConfirmPayment() async {
    // Validation
    if (_selectedContributionTypeId == null) {
      _showSnackBar('Please select a contribution type');
      return;
    }

    if (_amountController.text.trim().isEmpty) {
      _showSnackBar('Please enter an amount');
      return;
    }

    double? amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount');
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

    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    try {
      final result = await paymentProvider.makePayment(
        contributionTypeId: _selectedContributionTypeId!,
        amount: amount,
        telco: _getTelcoFromService(_selectedPaymentService!),
        phoneNumber: phoneNumber,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          // Navigate to payment status screen with success
          context.push(AppRoutes.paymentStatus);
        } else {
          _showSnackBar(
            result['message'] ?? 'Payment failed. Please try again.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('An error occurred. Please try again.');
      }
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
            child: Consumer<PaymentProvider>(
              builder: (context, paymentProvider, child) {
                return SingleChildScrollView(
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
                      paymentProvider.isLoading &&
                              paymentProvider.contributionTypes.isEmpty
                          ? const SizedBox(
                            height: 56,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select Contribution Type',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceInput,
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedContributionTypeId,
                                    hint: const Text(
                                      'Select',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: AppColors.textSecondary,
                                    ),
                                    items:
                                        paymentProvider.contributionTypes.map((
                                          type,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: type.id,
                                            child: Text(
                                              type.name,
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 14,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedContributionTypeId = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
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

                      // Error message
                      if (paymentProvider.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.error.withAlpha(51),
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
                                  paymentProvider.errorMessage!,
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Confirm Payment Button
                      AppButton(
                        text: 'Confirm Payment',
                        onPressed:
                            _isLoading || paymentProvider.isLoading
                                ? null // Keep disabled during loading state
                                : () {
                                  // Check validation before proceeding
                                  if (_phoneError != null ||
                                      _selectedContributionTypeId == null ||
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
                        isLoading: _isLoading || paymentProvider.isLoading,
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
