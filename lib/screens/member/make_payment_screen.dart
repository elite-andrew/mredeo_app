import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redeo_app/config/app_routes.dart';
import 'package:redeo_app/core/theme/app_colors.dart';
import 'package:redeo_app/widgets/common/custom_app_bar.dart';
import 'package:redeo_app/widgets/common/app_button.dart';
import 'package:redeo_app/widgets/common/app_text_field.dart';
import 'package:redeo_app/widgets/common/app_dropdown.dart';

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

  final List<String> _contributionTypes = ['Condolences', 'Sickness', 'Yearly'];

  final List<String> _paymentServices = [
    'T-pesa',
    'Halopesa',
    'Mixx by Yas',
    'M-Pesa',
    'AirtelMoney',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
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

    if (_phoneController.text.trim().isEmpty) {
      _showSnackBar('Please enter a phone number');
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
                  const Text(
                    'Enter Amount',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    hintText: 'Amount',
                    controller: _amountController,
                  ),

                  const SizedBox(height: 24),

                  // Phone Number Field
                  const Text(
                    'Payment number',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceInput,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '+255',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: '_',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Payment Service Dropdown
                  AppDropdown(
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
                    onPressed: _isLoading ? () {} : _handleConfirmPayment,
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
